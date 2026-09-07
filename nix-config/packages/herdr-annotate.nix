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
  version = "0.3.0-unstable-2026-09-07";

  src = fetchFromGitHub {
    owner = "plannotator";
    repo = "herdr-annotate";
    # managed by update-resource
    rev = "53b6e3211a4103c3de9d361eb3f3bacc7426d23b";
    # managed by update-resource
    hash = "sha256-2KOSud8fRsPC8q13tg+OOkgg+HkdoGLdjWxpZgo2Rbo=";
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
