{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  # managed by update-resource
  version = "3.2.0";
  source =
    {
      x86_64-linux = {
        url = "https://github.com/SoCkEt7/Livediff/releases/download/v${version}/livediff-v${version}-x86_64-unknown-linux-musl.tar.gz";
        # managed by update-resource
        hash = "sha256-5rn6eUWVLEwWMG0WsHgl7lrzoFZcG3jQd1Bt3Td+kcY=";
        directory = "livediff-v${version}-x86_64-unknown-linux-musl";
      };
      aarch64-darwin = {
        url = "https://github.com/SoCkEt7/Livediff/releases/download/v${version}/livediff-v${version}-aarch64-apple-darwin.tar.gz";
        # managed by update-resource
        hash = "sha256-AAlizuU/z/twkv23vrWO3KfvMTS3pN2BxUStV1n7z58=";
        directory = "livediff-v${version}-aarch64-apple-darwin";
      };
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "livediff is only supported on x86_64-linux and aarch64-darwin");
in
stdenvNoCC.mkDerivation {
  pname = "livediff";
  inherit version;

  src = fetchurl {
    inherit (source) url hash;
  };

  dontPatchELF = true;

  unpackPhase = "tar -xzf $src";

  installPhase = ''
    runHook preInstall
    install -Dm755 "${source.directory}/livediff" "$out/bin/livediff"
    runHook postInstall
  '';

  meta = {
    description = "Watch file diffs live in the terminal";
    homepage = "https://github.com/SoCkEt7/Livediff";
    license = lib.licenses.asl20;
    mainProgram = "livediff";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
