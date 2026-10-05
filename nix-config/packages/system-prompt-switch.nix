{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  # managed by update-resource
  version = "0.10.0";
in
stdenvNoCC.mkDerivation {
  pname = "system-prompt-switch";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/system-prompt-switch/-/system-prompt-switch-${version}.tgz";
    # managed by update-resource
    hash = "sha512-XjrSvClWXYOI+k4PDy9LPjbnGvjb5wKVYwQIkswjIbLtwmsBKHDAoUZlYo8lSbkUYdppri4Lk3Iv4d1DFO3O1w==";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    tar --strip-components=1 -xzf "$src" -C "$out"
    runHook postInstall
  '';

  meta = {
    description = "Session-scoped system prompt selection for OMP";
    homepage = "https://github.com/plantaeart/system-prompt-switch";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
}
