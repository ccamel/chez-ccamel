{
  config,
  lib,
  pkgs,
  ...
}:
let
  herdr = pkgs.callPackage ../../../packages/herdr.nix { };
  shepherdr = pkgs.callPackage ../../../packages/shepherdr.nix { };
in
{
  xdg.configFile."herdr/config.toml" = {
    source = ./config.toml;
    force = true;
  };

  xdg.dataFile."herdr/plugins/shepherdr/herdr-plugin.toml".source = ./herdr-plugin.toml;

  home = {
    packages = [
      herdr
      shepherdr
    ];

    activation = {
      replaceHerdrConfig = lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
        target="${config.xdg.configHome}/herdr/config.toml"
        if [[ -e "$target" && ! -L "$target" ]]; then
          ${pkgs.coreutils}/bin/rm -f "$target"
        fi
      '';

      linkShepherdr = lib.hm.dag.entryAfter [ "installPackages" ] ''
        ${herdr}/bin/herdr plugin link "${config.xdg.dataHome}/herdr/plugins/shepherdr" --enabled
      '';
    };
  };
}
