{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  version = "0.13.0";
  source =
    {
      x86_64-linux = {
        url = "https://github.com/daxartio/kdbx/releases/download/${version}/kdbx-${version}-x86_64-unknown-linux-musl.tar.gz";
        hash = "sha256-dbcMNdUEMp2K+DjsUUjlFNuAcnC7vQ/pfa2jNmHu2LQ=";
        directory = "kdbx-${version}-x86_64-unknown-linux-musl";
      };
      aarch64-darwin = {
        url = "https://github.com/daxartio/kdbx/releases/download/${version}/kdbx-${version}-aarch64-apple-darwin.tar.gz";
        hash = "sha256-MDeoVaxF1o13XE067yDUliXMW5x8ksZbWyrYGecpZkY=";
        directory = "kdbx-${version}-aarch64-apple-darwin";
      };
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "kdbx is only supported on x86_64-linux and aarch64-darwin");
in
stdenvNoCC.mkDerivation {
  pname = "kdbx";
  inherit version;

  src = fetchurl {
    inherit (source) url hash;
  };

  dontPatchELF = true;

  unpackPhase = "tar -xzf $src";

  installPhase = ''
    runHook preInstall
    install -Dm755 "${source.directory}/kdbx" "$out/bin/kdbx"
    runHook postInstall
  '';

  meta = {
    description = "Terminal password manager for KDBX databases";
    homepage = "https://github.com/daxartio/kdbx";
    license = lib.licenses.mit;
    mainProgram = "kdbx";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
