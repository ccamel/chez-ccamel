{ pkgs, ... }:
{
  programs.zsh = {
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
    envExtra = ''
      # Lig re-execs Zsh without -c, dropping commands from OMP's !/!! PTYs.
      # Keep it for terminal prompts, not shells started to execute a command.
      if [[ -o interactive && -v ZSH_EXECUTION_STRING ]]; then
        export LIG_DISABLE=1
      fi
    '';
    initContent = builtins.readFile ./config;
  };
}
