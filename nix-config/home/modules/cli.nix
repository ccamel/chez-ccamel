{ config, pkgs, ... }:
{
  # HerdR's embedded terminal does not apply bold ANSI colours as bright variants.
  home.sessionVariables.EZA_COLORS = "di=94";

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    nix-index-database.comma.enable = true;

    bat = {
      enable = true;
      config = {
        pager = "less";
        italic-text = "always";
        map-syntax = ".ignore:.gitignore";
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  home.packages = with pkgs; [
    # Search and navigation
    ripgrep
    fd

    # Files and output
    eza
    tree
    file
    imagemagick

    # Data and HTTP
    jq
    yq-go
    curl
    wget

    # System
    btop
    dust
    procs
    which
    just

    age
    gnupg
    sops
  ];
}
