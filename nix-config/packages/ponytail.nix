{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  # managed by update-resource
  version = "4.10.0";
in
stdenvNoCC.mkDerivation {
  pname = "ponytail";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@dietrichgebert/ponytail/-/ponytail-${version}.tgz";
    # managed by update-resource
    hash = "sha512-O2H+RWO0ojk8D8yz9q1F82ybKTXpYtrBb7mHkQT+/iCtsXndAxJo05KU1hkLPjV203ABq+cj89Th9jFvdnc6Mg==";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    tar --strip-components=1 -xzf "$src" -C "$out"
    runHook postInstall
  '';

  meta = {
    description = "Lazy senior dev mode for AI agents";
    homepage = "https://github.com/DietrichGebert/ponytail";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
}
