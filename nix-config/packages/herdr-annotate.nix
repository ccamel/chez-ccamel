{
  bun,
  fetchFromGitHub,
  lib,
  stdenvNoCC,
  wl-clipboard,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr-annotate";
  version = "0.2.0-unstable-2026-08-27";

  src = fetchFromGitHub {
    owner = "plannotator";
    repo = "herdr-annotate";
    rev = "026c1d8f35807edaabe241185879fccc5b43a1f3";
    hash = "sha256-sqlvucnGvSNWTswtaG8Zs3BzoP/LXqY85zCALR7V3EU=";
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
