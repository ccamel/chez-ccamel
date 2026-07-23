{ ... }:
{
  imports = [
    ./modules/cli.nix
    ./modules/git.nix
    ./modules/neovim
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases.cat = "bat --style=plain --paging=never";

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
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$nix_shell$character";
      directory.truncation_length = 0;
      nix_shell.format = "via [$symbol$state( \\($name\\))]($style) ";
    };
  };

}
