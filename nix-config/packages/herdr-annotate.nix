{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr-annotate";
  # managed by update-resource
  version = "0.5.0-unstable-2026-09-21";

  src = fetchFromGitHub {
    owner = "plannotator";
    repo = "herdr-annotate";
    # managed by update-resource
    rev = "d02b0b42cf1955a3b206959659f1833622f213b8";
    # managed by update-resource
    hash = "sha256-ra+iX1QrsaPe0lmbJ+FOxMp2YWP1YsvPUHPoB3HgOqY=";
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
