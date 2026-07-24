{ config, pkgs, ... }:
{

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

  programs.zsh.initContent = ''
    toolbox() {
      if (( $# != 1 )); then
        print -u2 "usage: toolbox <agentic|devops|agentic-devops>"
        return 2
      fi

      case "$1" in
        agentic|devops|agentic-devops) ;;
        *)
          print -u2 "unknown toolbox: $1"
          return 2
          ;;
      esac

      nix develop \
        "${config.home.homeDirectory}/src/mine/chez-ccamel/nix-config#$1" \
        --command zsh
    }
  '';

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
