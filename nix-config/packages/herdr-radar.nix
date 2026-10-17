{
  fetchFromGitHub,
  lib,
  nodejs,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr-radar";
  # managed by update-resource
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "hhdebb";
    repo = "herdr-radar";
    # managed by update-resource
    rev = "ae46869a0a40f675a333342510c915dbc155ae6a";
    # managed by update-resource
    hash = "sha256-TFQ3ryEU41FOJ0Wz+VIKv19xumjGWAeytLn4/JrbmD8=";
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
