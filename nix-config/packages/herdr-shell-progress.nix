{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr-shell-progress";
  # managed by update-resource
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "bayoudhi";
    repo = "herdr-shell-progress";
    # managed by update-resource
    rev = "681168ca4befe2be24c6fc2e28585fd265ca5bd1";
    # managed by update-resource
    hash = "sha256-40FECfvJn6w9lwp+tERZJKMNW0sMK5Ms9RrUTpxqFDU=";
  };

  cargoLock.lockFile = "${finalAttrs.src}/Cargo.lock";

  # The upstream integration tests need executable interactive shells in the build sandbox.
  doCheck = false;

  installPhase = ''
    runHook preInstall
    cp -R . "$out"
    install -Dm755 target/*/release/herdr-shell-progress "$out/target/release/herdr-shell-progress"
    runHook postInstall
  '';

  meta = {
    description = "HerdR plugin that shows progress for slow shell commands";
    homepage = "https://github.com/bayoudhi/herdr-shell-progress";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
})
