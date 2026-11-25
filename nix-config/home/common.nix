{ lib, pkgs, ... }:
{
  home.sessionVariables.PONYTAIL_DEFAULT_MODE = "off";
  xdg.configFile."ponytail/config.json".text = builtins.toJSON {
    defaultMode = "off";
  };
  home.activation.installOmpConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -Dm600 \
      ${
        (pkgs.formats.yaml { }).generate "omp-config.yml" (import ../toolboxes/omp.nix { inherit pkgs; })
      } \
      "$HOME/.omp/agent/config.yml"
  '';
  imports = [
    ./modules/cli.nix
    ./modules/git.nix
    ./modules/neovim
    ./modules/zsh
    ./modules/starship
  ];
}
