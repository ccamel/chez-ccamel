_: {
  programs.starship.enable = true;
  programs.starship.enableZshIntegration = true;
  xdg.configFile."starship.toml".source = ./config.toml;
}
