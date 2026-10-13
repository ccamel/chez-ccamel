{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr-annotate";
  # managed by update-resource
  version = "0.9.1-unstable-2026-10-12";

  src = fetchFromGitHub {
    owner = "plannotator";
    repo = "herdr-annotate";
    # managed by update-resource
    rev = "ceab050b77bea07bbeabdfda5c138be8c9c5c517";
    # managed by update-resource
    hash = "sha256-Q/HgVn1gEAMMavWDQp8Rmz7R7qK5u0QweLkcpYL+otE=";
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
