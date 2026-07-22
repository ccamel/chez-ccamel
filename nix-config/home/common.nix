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

}
