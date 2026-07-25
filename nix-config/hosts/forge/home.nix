{ inputs, ... }:
{
  imports = [
    ../../home/common.nix
    ../../home/modules/sops.nix
    ../../home/modules/git-signing.nix
    ../../home/modules/git-mine.nix
    ../../home/modules/git-corp.nix
    inputs.nix-index-database.homeModules.nix-index
  ];

  home = {
    username = "chris";
    homeDirectory = "/home/chris";
    stateVersion = "25.11";
  };

  home.sessionVariables.CHEZ_CCAMEL_ROOT = "/home/chris/src/mine/chez-ccamel";

  xdg.enable = true;

}
