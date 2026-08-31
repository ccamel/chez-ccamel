{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  version = "4.9.0";
in
stdenvNoCC.mkDerivation {
  pname = "ponytail";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@dietrichgebert/ponytail/-/ponytail-${version}.tgz";
    hash = "sha512-OSdybtBZ3uDd5m/+zyz4h8/+BVBR9nGFhqTDmQkQb1v7k4Vfc1qql78naY64UjocdBPqR94htZEkKu2wpKTJaw==";
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
