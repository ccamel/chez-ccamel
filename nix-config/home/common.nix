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

    delta = {
      enable = true;
      enableGitIntegration = true;
    };


    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        pull.ff = "only";
        push.autoSetupRemote = true;
      };
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = "vim";
        prompt = "enabled";
        pager = "bat";
        aliases.co = "pr checkout";
      };
    };


    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      shellAliases.cat = "bat --style=plain --paging=never";

      oh-my-zsh = {
        enable = true;
        theme = "mh";
        plugins = [
          "git"
          "history"
        ];
      };
      history = {
        path = "$HOME/.zsh_history";
        size = 100000;
        save = 100000;
        share = true;
        ignoreDups = true;
        expireDuplicatesFirst = true;
      };
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

    # Git
    tig

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
