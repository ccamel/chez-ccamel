{
  fetchFromGitHub,
  lib,
  python3,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr-remote";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "dcolinmorgan";
    repo = "herdr-remote";
    rev = "1f5bd32b5121af92c21c9a3b123b10d508f29365";
    hash = "sha256-mTHcGe806gLnDdBo/K4QJlIDA8IkFWk2LYbQeuaELig=";
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
