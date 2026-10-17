{
  fetchFromGitHub,
  lib,
  python3,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr-remote";
  # managed by update-resource
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "dcolinmorgan";
    repo = "herdr-remote";
    # managed by update-resource
    rev = "6843636df54386781de122211d8a8d354fac2dbd";
    # managed by update-resource
    hash = "sha256-D1bqHgIRumsSS8ejleC+RH0CUp2Uyr+2MNWSMy9NTHs=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm444 herdr-plugin.toml "$out/herdr-plugin.toml"
    install -Dm444 relay/on_event.py "$out/relay/on_event.py"
    substituteInPlace "$out/herdr-plugin.toml" \
      --replace-fail '["uv", "run", "--script",' '["${python3}/bin/python3",'
    runHook postInstall
  '';

  meta = {
    description = "HerdR plugin for remote agent monitoring and approvals";
    homepage = "https://github.com/dcolinmorgan/herdr-remote";
    license = lib.licenses.agpl3Plus;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
})
