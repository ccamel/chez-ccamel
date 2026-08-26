{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  version = "1.5.5";
in
stdenvNoCC.mkDerivation {
  pname = "omp-undo-redo";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@baylarsadigov/omp-undo-redo/-/omp-undo-redo-${version}.tgz";
    hash = "sha512-4CjU4601TKTO8oaC9IX0ckYxVBG0w/Bnn6DT4ArQNTI0goa74HvUTA4PgFm0SLNhxTAL05U3Yvmd3rdfLZHdWw==";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    tar --strip-components=1 -xzf "$src" -C "$out"
    runHook postInstall
  '';

  meta = {
    description = "Undo and redo session navigation for Oh My Pi";
    homepage = "https://github.com/Baylar55/omp-undo-redo";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
}
