{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    history = {
      path = "$HOME/.zsh_history";
      size = 999999999;
      save = 999999999;
    };
  };
}
