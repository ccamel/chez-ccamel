{ config, inputs, ... }:
{
  imports = [
    ../../home/common.nix
    ../../home/modules/git-mine.nix
    inputs.nix-index-database.homeModules.nix-index
  ];

  home = {
    username = "chris";
    homeDirectory = "/Users/chris";
    stateVersion = "25.11";
    sessionVariables.CHEZ_CCAMEL_ROOT = "/Users/chris/src/mine/chez-ccamel";
  };

  xdg.enable = true;

  home.packages = [ config.programs.home-manager.package ];

  home.file.".gitconfig".source = config.xdg.configFile."git/config".source;
}
