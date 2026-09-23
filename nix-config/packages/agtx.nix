{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  # managed by update-resource
  version = "1.0.6";
  source =
    {
      x86_64-linux = {
        url = "https://github.com/fynnfluegge/agtx/releases/download/v${version}/agtx-v${version}-x86_64-linux.tar.gz";
        # managed by update-resource
        hash = "sha256-h/k/INwGm56jz5Je+GIBPBGCXUTtPi+UujH8t4SxKzM=";
      };
      aarch64-darwin = {
        url = "https://github.com/fynnfluegge/agtx/releases/download/v${version}/agtx-v${version}-aarch64-darwin.tar.gz";
        # managed by update-resource
        hash = "sha256-UcHrcPgpPkGGe73Caai+86ssRXUcSDCKQpLeGx5cMuM=";
      };
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "agtx is only supported on x86_64-linux and aarch64-darwin");
in
stdenvNoCC.mkDerivation {
  pname = "agtx";
  inherit version;

  src = fetchurl source;

  dontPatchELF = true;

  unpackPhase = "tar -xzf $src";

  installPhase = ''
    runHook preInstall
    install -Dm755 agtx "$out/bin/agtx"
    runHook postInstall
  '';

  meta = {
    description = "Terminal-native development environment for coding agents";
    homepage = "https://github.com/fynnfluegge/agtx";
    license = lib.licenses.asl20;
    mainProgram = "agtx";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
