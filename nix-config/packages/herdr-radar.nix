{
  fetchFromGitHub,
  lib,
  nodejs,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr-radar";
  # managed by update-resource
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "hhdebb";
    repo = "herdr-radar";
    # managed by update-resource
    rev = "54a30926c43b2867ddb7bbb7d167492751e3c43a";
    # managed by update-resource
    hash = "sha256-jQ8p1g/2jWo+s7ob65dFwODkeS9pV8X2NH+O9eZdDIM=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    cp -R . "$out"
    substituteInPlace "$out/herdr-plugin.toml" \
      --replace-fail '["node",' '["${nodejs}/bin/node",'
    runHook postInstall
  '';

  meta = {
    description = "HerdR plugin for agent status, workspace grouping, and vendor marks in the sidebar";
    homepage = "https://github.com/hhdebb/herdr-radar";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
})
