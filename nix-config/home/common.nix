{ pkgs, ... }:
{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        pull.ff = "only";
        push.autoSetupRemote = true;
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
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
        size = 999999999;
        save = 999999999;
      };
    };
  };

  home.packages = with pkgs; [
    age
    gnupg
    sops
  ];
}
