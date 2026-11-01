{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr-bar";
  # managed by update-resource
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "jeffarese";
    repo = "herdr-bar";
    # managed by update-resource
    rev = "d642f7964231b86e82e1ac7f3a390fd5baa03e98";
    # managed by update-resource
    hash = "sha256-7ybX/DwOZkI7yr0U6fszlerx5/96mGO9DtLXoA4DuHs=";
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
