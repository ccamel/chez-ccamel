{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  # managed by update-resource
  version = "0.47.0";
  source =
    {
      x86_64-linux = {
        url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-unknown-linux-musl.tar.gz";
        # managed by update-resource
        hash = "sha256-fAF12Gf5bE+PeIR5r4LKjwmQ6pRCJiaINNIkpSUYb7c=";
      };
      aarch64-darwin = {
        url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-aarch64-apple-darwin.tar.gz";
        # managed by update-resource
        hash = "sha256-Nhf5qV1TbgtrueLG0SHYHD2P2O8ExbKmBfXnsDCaR9I=";
      };
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "rtk is only supported on x86_64-linux and aarch64-darwin");
in
stdenvNoCC.mkDerivation {
  pname = "rtk";
  inherit version;

  src = fetchurl source;

  dontPatchELF = true;

  unpackPhase = "tar -xzf $src";

  installPhase = ''
    runHook preInstall
    install -Dm755 rtk "$out/bin/rtk"
    runHook postInstall
  '';

  meta = {
    description = "Rust Token Killer command-output optimizer";
    homepage = "https://github.com/rtk-ai/rtk";
    license = lib.licenses.asl20;
    mainProgram = "rtk";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
