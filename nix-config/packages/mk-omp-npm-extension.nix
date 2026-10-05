{
  fetchurl,
  lib,
  stdenvNoCC,
}:
{
  pname,
  npmPackage,
  version,
  hash,
  description,
  homepage,
  license,
}:
stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://registry.npmjs.org/${npmPackage}/-/${lib.last (lib.splitString "/" npmPackage)}-${version}.tgz";
    inherit hash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    tar --strip-components=1 -xzf "$src" -C "$out"
    runHook postInstall
  '';

  meta = {
    inherit description homepage;
    license = lib.licenses.${license};
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
}
