{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  # managed by update-resource
  version = "3.4.0";
  source =
    {
      x86_64-linux = {
        url = "https://github.com/SoCkEt7/Livediff/releases/download/v${version}/livediff-v${version}-x86_64-unknown-linux-musl.tar.gz";
        # managed by update-resource
        hash = "sha256-UXtAknilDLQ+8bONGmeBa5dnZ2fys44N9i5/vKrmGk8=";
        directory = "livediff-v${version}-x86_64-unknown-linux-musl";
      };
      aarch64-darwin = {
        url = "https://github.com/SoCkEt7/Livediff/releases/download/v${version}/livediff-v${version}-aarch64-apple-darwin.tar.gz";
        # managed by update-resource
        hash = "sha256-N5JGoSz1LXUlgiQlrkpvpmW93QXpyQp5UuaUITA6Edc=";
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
