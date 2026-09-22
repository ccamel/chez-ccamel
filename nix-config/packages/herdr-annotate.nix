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
    rev = "99002e24525a9ae327450cd83a17b1e86b2ee81f";
    # managed by update-resource
    hash = "sha256-zZVMK3BBNGPunjLur2CcIZH9z/NOkV0JH6e/PCyUezs=";
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
