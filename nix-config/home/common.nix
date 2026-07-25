{ pkgs, ... }:
{
  imports = [
    ./modules/cli.nix
    ./modules/git.nix
    ./modules/neovim
  ];

  programs = {
    zsh = {
      enable = true;
      plugins = [
        {
          name = "zsh-vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        cat = "bat --style=plain --paging=never";
        ls = "eza --icons";
        ll = "eza --icons -l";
        la = "eza --icons -la";
        lt = "eza --icons --tree";
      };

      history = {
        path = "$HOME/.zsh_history";
        size = 100000;
        save = 100000;
        share = true;
        ignoreDups = true;
        expireDuplicatesFirst = true;
      };
      initContent = ''
        export GPG_TTY="$(tty)"
        export EDITOR="vim"

        take() {
          if (( $# != 1 )); then
            print -u2 "usage: take <directory>"
            return 2
          fi

          mkdir -p -- "$1" && cd -- "$1"
        }

        bindkey '^[[1;5D' backward-word
        bindkey '^[[1;5C' forward-word
      '';
    };

    atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = false;
        update_check = false;
        search_mode = "fuzzy";
        filter_mode = "global";
        style = "compact";
        inline_height = 8;
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        format = "$directory$git_branch$git_status$nix_shell$character";
        directory.truncation_length = 0;
        nix_shell.format = "via [$symbol$state( \\($name\\))]($style) ";
        character = {
          success_symbol = "[INSERT](bold green)";
          error_symbol = "[INSERT](bold red)";
          vimcmd_symbol = "[NORMAL](bold yellow)";
        };
      };
    };
  };

}
