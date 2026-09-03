{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  # managed by update-resource
  version = "0.8.2";
  source =
    {
      x86_64-linux = {
        url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-x86_64";
        # managed by update-resource
        hash = "sha256-l2FQoU1JDJSyQ+ouGn6y37Z/EuNrGC25CTb2co5q7PQ=";
      };
      aarch64-darwin = {
        url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-aarch64";
        # managed by update-resource
        hash = "sha256-pdT01QTYswnJH4EQUFWTAPq6MSWEJfU8UIUvyW9q5XQ=";
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
