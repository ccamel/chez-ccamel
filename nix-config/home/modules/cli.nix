{ config, pkgs, ... }:
{
  home = {
    # HerdR's embedded terminal does not apply bold ANSI colours as bright variants.
    sessionVariables.EZA_COLORS = "di=94";
    sessionPath = [ "$HOME/.local/bin" ];
    file.".local/bin/.keep".text = "";

    packages = with pkgs; [
      # Search and navigation
      ripgrep
      fd

      # Files and output
      eza
      tree
      file
      glow
      imagemagick
      exiftool
      # Data and scripting
      jq
      yq-go
      python3

      # HTTP
      curl
      wget

      # System
      btop
      dust
      procs
      which
      just
      lazydocker

      age
      gnupg
      sops
    ];
  };

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

}
