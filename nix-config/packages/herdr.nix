{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  # managed by update-resource
  version = "0.9.1";
  source =
    {
      x86_64-linux = {
        url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-x86_64";
        # managed by update-resource
        hash = "sha256-KgL+0WvrZR7wBuHUPwSPZSyk3FitBTzS1ERQVj1cVLc=";
      };
      aarch64-darwin = {
        url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-aarch64";
        # managed by update-resource
        hash = "sha256-X8en5636ylb6gKqJ3LAlaTNXJo2rgoW5zi0IojE8id4=";
      };
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "herdr is only supported on x86_64-linux and aarch64-darwin");
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr";
  inherit version;

  src = fetchurl source;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/herdr"
    runHook postInstall
  '';

  meta = {
    description = "Terminal-native multiplexer for AI coding agents";
    homepage = "https://github.com/ogulcancelik/herdr";
    license = lib.licenses.agpl3Plus;
    mainProgram = "herdr";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
