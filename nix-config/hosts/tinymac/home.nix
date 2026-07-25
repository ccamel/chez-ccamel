{ config, inputs, ... }:
{
  imports = [
    ../../home/common.nix
    ../../home/modules/sops.nix
    ../../home/modules/git-signing.nix
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

  xdg.configFile."ghostty/config".text = ''
    # THEME SETTINGS
    theme = iTerm2 Tango Dark
    cursor-style = block
    cursor-style-blink = true
    shell-integration-features = no-cursor

    # FONT SETTINGS
    font-family = ProggyClean Nerd Font Mono
    font-size = 19

    # WINDOW SETTINGS
    window-padding-balance = true
    window-save-state = always
    window-colorspace = "display-p3"
    adjust-cell-height = 35%
    link-url = true
    macos-titlebar-style = tabs

    # MOUSE
    mouse-hide-while-typing = true
    mouse-scroll-multiplier = 2

    # SPLITS
    unfocused-split-opacity = 0.5
  '';
}
