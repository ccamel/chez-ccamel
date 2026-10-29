{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr-bar";
  # managed by update-resource
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "jeffarese";
    repo = "herdr-bar";
    # managed by update-resource
    rev = "a88c7b06c7a0f354d6120d465b0caa56fbde3fbf";
    # managed by update-resource
    hash = "sha256-KX1uB47XJdvjF02Q27bywKJ+TCkKvMpz7QPUHgGGeoA=";
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
