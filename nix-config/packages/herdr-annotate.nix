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
  version = "0.3.0-unstable-2026-09-08";

  src = fetchFromGitHub {
    owner = "plannotator";
    repo = "herdr-annotate";
    # managed by update-resource
    rev = "bfe0de8af9912b90a8a89a07a58a7b9b0dcfea88";
    # managed by update-resource
    hash = "sha256-+fvhp6goKaYX8WsI0oGeTYkpfX/wnGFkmyCzR0WqdB4=";
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
