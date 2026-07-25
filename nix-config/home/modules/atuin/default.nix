{ ... }:
{
  programs.atuin.enable = true;
  programs.atuin.enableZshIntegration = true;
  xdg.configFile."atuin/config.toml".source = ./config.toml;
}
