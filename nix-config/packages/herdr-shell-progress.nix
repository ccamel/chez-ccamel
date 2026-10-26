{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "herdr-shell-progress";
  # managed by update-resource
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "bayoudhi";
    repo = "herdr-shell-progress";
    # managed by update-resource
    rev = "0e30b18deef1b7089212569f9b06ec43bd62bae1";
    # managed by update-resource
    hash = "sha256-dki4e5PXDzbSvplZM/57ZBAXOzglyerrGZYB4snAfJY=";
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
