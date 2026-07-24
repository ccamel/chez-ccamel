{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  source =
    {
      x86_64-linux = {
        url = "https://github.com/ogulcancelik/herdr/releases/download/v0.7.5/herdr-linux-x86_64";
        hash = "sha256-PcgyiAc+TC08Z5ow576XvMqRQcb9F9u7khkULpXFklM=";
      };
      aarch64-darwin = {
        url = "https://github.com/ogulcancelik/herdr/releases/download/v0.7.5/herdr-macos-aarch64";
        hash = "sha256-NzUFRrABJVWUO5Lq+WJmXeTiZDlbrrRCJ7gBXo/1sNY=";
      };
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "herdr is only supported on x86_64-linux and aarch64-darwin");
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr";
  version = "0.7.5";

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
