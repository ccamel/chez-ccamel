{
  fetchFromGitHub,
  lib,
  nodejs,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr-radar";
  # managed by update-resource
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "hhdebb";
    repo = "herdr-radar";
    # managed by update-resource
    rev = "79a81bbddc017a4349713e282b1a01ee360c46de";
    # managed by update-resource
    hash = "sha256-ag9W4FlMdjO+3SmaJObNXI48WxCdx/NulMsSXvxxBCY=";
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
