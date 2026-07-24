{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  version = "0.43.0";
  source =
    {
      x86_64-linux = {
        url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-unknown-linux-musl.tar.gz";
        hash = "sha256-/4oed2ZJbhdSkaha7KHcl8n/bfM+UeWJPR+8eP6ipgk=";
      };
      aarch64-darwin = {
        url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-aarch64-apple-darwin.tar.gz";
        hash = "sha256-ihfkmsvTeJl+sh0Otvf4YREfNbT8mxx07fTHRI5XbGU=";
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
    platforms = [ "x86_64-linux" "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
