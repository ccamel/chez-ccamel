{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr-annotate";
  # managed by update-resource
  version = "0.12.1-unstable-2026-11-26";

  src = fetchFromGitHub {
    owner = "plannotator";
    repo = "herdr-annotate";
    # managed by update-resource
    rev = "65eed2761187e4fe78f85d33d9120867e62c0531";
    # managed by update-resource
    hash = "sha256-7jf1p1EnkKo1su/H3hm9TMHchi8T06TopGv46L7TkAU=";
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
