{ config, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  home.packages = with pkgs; [
    gcc
    gnumake
    tree-sitter
    unzip
  ];

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "/home/chris/src/mine/chez-ccamel/nix-config/home/modules/neovim/config";
}
