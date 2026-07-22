{ pkgs, ... }:
{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

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

    age
    gnupg
    sops
  ];
}
