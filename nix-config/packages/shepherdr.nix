{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "shepherdr";
  version = "0.1.0-unstable-2026-07-24";

  src = fetchFromGitHub {
    owner = "afogel";
    repo = "shepherdr";
    rev = "a502f14f71129c08ea9e52e185a627dd27c1da71";
    hash = "sha256-9JuuOMxSfz2LfoXsRI4l+Zs1nkAr30Nxr8LFJ21zcyE=";
  };

  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  cargoBuildFlags = [ "--ignore-rust-version" ];
  cargoTestFlags = [ "--ignore-rust-version" ];

  meta = {
    description = "Herdr plugin for auditable delegated coding agents";
    homepage = "https://github.com/afogel/shepherdr";
    license = lib.licenses.mit;
    mainProgram = "shepherdr";
  };
})
