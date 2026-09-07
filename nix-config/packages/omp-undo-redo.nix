{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  # managed by update-resource
  version = "1.6.1";
in
stdenvNoCC.mkDerivation {
  pname = "omp-undo-redo";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@baylarsadigov/omp-undo-redo/-/omp-undo-redo-${version}.tgz";
    # managed by update-resource
    hash = "sha512-FbDkcpQOga8ZV+nZnUWIuxUX0HwLiFutyNjtKLfO8pHH8IuRIDSEsW7E5BRxSlelskykZ5PoXfPfMvOJA4VSgQ==";
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
