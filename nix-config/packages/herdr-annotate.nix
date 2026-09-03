{
  bun,
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  wl-clipboard,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr-annotate";
  # managed by update-resource
  version = "0.3.0-unstable-2026-08-31";

  src = fetchFromGitHub {
    owner = "plannotator";
    repo = "herdr-annotate";
    # managed by update-resource
    rev = "bccf884b874f5f39ccbef1bb6ac67625c5fb5d54";
    # managed by update-resource
    hash = "sha256-h3ibUCd2uLtQENU0IRNJzefZH2pnK13mzCoHmGc1EeU=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -R . "$out"
    substituteInPlace "$out/herdr-plugin.toml" \
      --replace-fail '["bun",' '["${bun}/bin/bun",'
    ${lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
      substituteInPlace "$out/src/clipboard.ts" \
        --replace-fail 'command: "wl-paste"' 'command: "${wl-clipboard}/bin/wl-paste"' \
        --replace-fail 'command: "wl-copy"' 'command: "${wl-clipboard}/bin/wl-copy"'
    ''}

    runHook postInstall
  '';

  meta = {
    description = "HerdR plugin for annotating terminal selections as agent context";
    homepage = "https://github.com/plannotator/herdr-annotate";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
})
