{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  # managed by update-resource
  version = "0.6.16";
in
stdenvNoCC.mkDerivation {
  pname = "omp-telegram";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@tickernelz/omp-telegram/-/omp-telegram-${version}.tgz";
    # managed by update-resource
    hash = "sha512-e3Ji11EcrOMP/AoDviF90iTvhvi8H1c8hwOFqZ79d3FVV5vHLQs7XLVP+VUAeStYABjoOz/UuBmaw48Rkc3GqA==";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    tar --strip-components=1 -xzf "$src" -C "$out"
    runHook postInstall
  '';

  meta = {
    description = "Telegram runtime adapter for OMP";
    homepage = "https://github.com/tickernelz/omp-telegram";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
}
