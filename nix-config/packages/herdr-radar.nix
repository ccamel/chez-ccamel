{
  fetchFromGitHub,
  lib,
  nodejs,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr-radar";
  # managed by update-resource
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "hhdebb";
    repo = "herdr-radar";
    # managed by update-resource
    rev = "dd42772da4b8b9e18660d653d08149c7da1d2964";
    # managed by update-resource
    hash = "sha256-aFQqPFSNG33Ois2niAwKrQXqNWgNqreO282PdXSzSEw=";
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
