{
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  # managed by update-resource
  version = "4.10.3";
in
stdenvNoCC.mkDerivation {
  pname = "ponytail";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@dietrichgebert/ponytail/-/ponytail-${version}.tgz";
    # managed by update-resource
    hash = "sha512-v5w8QH7t9sMbUnzAsAQQ72++hXzs19mm+rkbJIdGQrfaL2RtvxWu2qaGhM54//o+T35gGQxTFaCsApzt0pgp2A==";
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
