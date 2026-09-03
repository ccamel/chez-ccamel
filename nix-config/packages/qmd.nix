{
  bun,
  lib,
  src,
  stdenvNoCC,
  upstreamQmd,
}:
let
  packageJson = builtins.fromJSON (builtins.readFile "${src}/package.json");
  inherit (packageJson) version;

  # Bun ships its own root store and ignores the system one, so a TLS-intercepting
  # proxy breaks `bun install` inside the sandbox. Nix bind-mounts the daemon's
  # `ssl-cert-file` here for fixed-output derivations. `NIX_SSL_CERT_FILE` is
  # deliberately `/no-cert-file.crt` in the sandbox, so the literal path is the
  # reliable handle. node_modules includes platform-native binaries, so its
  # fixed-output hash is intentionally platform-specific.
  hostCaBundle = "/etc/ssl/certs/ca-certificates.crt";

  nodeModulesHashes = {
    # managed by update-resource
    x86_64-linux = "sha256-jvq2TO0SxEV1BHyT6C32VQ916wMTM/D1nsV2rNcJQSo=";
    # managed by update-resource
    aarch64-darwin = "sha256-9vvR3KLmBc+4bfyWEyyM8FHWg+DfiDzUlwqUlm3NFc8=";
  };
  targetPlatform =
    {
      x86_64-linux = {
        os = "linux";
        cpu = "x64";
      };
      aarch64-darwin = {
        os = "darwin";
        cpu = "arm64";
      };
    }
    .${stdenvNoCC.hostPlatform.system};

  nodeModules = stdenvNoCC.mkDerivation {
    pname = "qmd-node-modules";
    inherit src version;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    nativeBuildInputs = [ bun ];
    dontConfigure = true;

    buildPhase = ''
      export HOME="$(mktemp -d)"
      if [ -r ${hostCaBundle} ]; then
        export NODE_EXTRA_CA_CERTS=${hostCaBundle}
      fi

      bun install \
        --backend copyfile \
        --network-concurrency 4 \
        --os ${targetPlatform.os} \
        --cpu ${targetPlatform.cpu} \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --production
    '';

    installPhase = ''
      mkdir -p "$out"
      cp -R node_modules "$out/"
    '';

    dontFixup = true;
    outputHash = nodeModulesHashes.${stdenvNoCC.hostPlatform.system};
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };
in
upstreamQmd.overrideAttrs (_old: {
  inherit src;

  buildPhase = ''
    export HOME="$(mktemp -d)"

    cp -R ${nodeModules}/node_modules ./
    chmod -R u+w node_modules

    (cd node_modules/better-sqlite3 && node-gyp rebuild --release)
  '';
})
