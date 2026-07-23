{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr";
  version = "0.7.5";

  src = fetchurl {
    url = "https://github.com/ogulcancelik/herdr/releases/download/v${finalAttrs.version}/herdr-linux-x86_64";
    hash = "sha256-PcgyiAc+TC08Z5ow576XvMqRQcb9F9u7khkULpXFklM=";
  };

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
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
