{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  # managed by update-resource
  version = "0.8.0";
  source =
    {
      x86_64-linux = {
        url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-x86_64";
        # managed by update-resource
        hash = "sha256-uHLqfkD6LLF+hXrJtisb8m23tAPGIvXS8/WzX26azSg=";
      };
      aarch64-darwin = {
        url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-macos-aarch64";
        # managed by update-resource
        hash = "sha256-1Tqfk/zP38xVYyknv1EAL1rdCqeZC831CP+9hKxlgXg=";
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
