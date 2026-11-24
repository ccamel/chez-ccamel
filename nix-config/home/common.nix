{ ... }:
{
  home.sessionVariables.PONYTAIL_DEFAULT_MODE = "off";
  xdg.configFile."ponytail/config.json".text = builtins.toJSON {
    defaultMode = "off";
  };
  imports = [
    ./modules/cli.nix
    ./modules/git.nix
    ./modules/neovim
    ./modules/zsh
    ./modules/starship
  ];
}
