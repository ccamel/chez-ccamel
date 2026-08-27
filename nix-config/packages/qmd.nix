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
  # `ssl-cert-file` here for fixed-output derivations, so this hands Bun exactly the
  # trust the host is configured with: the Zscaler-augmented bundle on forge, the
  # plain roots elsewhere. `NIX_SSL_CERT_FILE` is deliberately `/no-cert-file.crt`
  # in the sandbox, so the literal path is the only reliable handle. node_modules
  # stays content-addressed, so every host still produces identical output.
  hostCaBundle = "/etc/ssl/certs/ca-certificates.crt";

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
    outputHash = "sha256-jvq2TO0SxEV1BHyT6C32VQ916wMTM/D1nsV2rNcJQSo=";
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
