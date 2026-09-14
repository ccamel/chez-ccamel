{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr-annotate";
  # managed by update-resource
  version = "0.4.0-unstable-2026-09-10";

  src = fetchFromGitHub {
    owner = "plannotator";
    repo = "herdr-annotate";
    # managed by update-resource
    rev = "7c8f5a177b8285dc56efc471ef04f7ab44a2b4b6";
    # managed by update-resource
    hash = "sha256-f+/2mDs8d5JICqbwzC7/tIYdLlb8NPJuV00Odp4CMSU=";
  };

  cargoRoot = "rust";
  buildAndTestSubdir = "rust";
  cargoLock.lockFile = "${finalAttrs.src}/rust/Cargo.lock";
  cargoBuildFlags = [ "--ignore-rust-version" ];
  cargoTestFlags = [ "--ignore-rust-version" ];

  installPhase = ''
    runHook preInstall
    cp -R . "$out"
    install -Dm755 target/*/release/herdr-annotate "$out/bin/herdr-annotate.exe"
    runHook postInstall
  '';

  meta = {
    description = "HerdR plugin for annotating terminal selections as agent context";
    homepage = "https://github.com/plannotator/herdr-annotate";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
})
