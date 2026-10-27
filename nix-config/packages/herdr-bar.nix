{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr-bar";
  # managed by update-resource
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "jeffarese";
    repo = "herdr-bar";
    # managed by update-resource
    rev = "1ec84901d7922987b4273e4ae98c33bd5d251fab";
    # managed by update-resource
    hash = "sha256-CYLnUJ7BQZmtnp7X1vtqTxLjEOaWsFQ2bHyghLG8oM0=";
  };

  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  cargoBuildFlags = [ "--ignore-rust-version" ];
  cargoTestFlags = [ "--ignore-rust-version" ];
  # Tests inspect /proc which is restricted in the Nix build sandbox.
  doCheck = false;

  postInstall = ''
    install -Dm444 herdr-plugin.toml "$out/herdr-plugin.toml"
  '';

  meta = {
    description = "Cmd+K command bar for Herdr with agent icons, fuzzy search, and automatic tab titles";
    homepage = "https://github.com/jeffarese/herdr-bar";
    license = lib.licenses.mit;
    mainProgram = "herdr-bar";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
})
