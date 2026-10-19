{
  fetchFromGitHub,
  lib,
  nodejs,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr-radar";
  # managed by update-resource
  version = "1.4.8";

  src = fetchFromGitHub {
    owner = "hhdebb";
    repo = "herdr-radar";
    # managed by update-resource
    rev = "17551e90ba4da614144dc60ab560e282db51364a";
    # managed by update-resource
    hash = "sha256-vf8A7G94aC7zfjZ9KW944lzqwNssS3HS6DmRk/bQ+8o=";
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
