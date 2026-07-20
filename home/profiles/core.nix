{ pkgs, ... }:
{
  imports = [
    ../programs/direnv.nix
    ../programs/git.nix
    ../programs/zsh.nix
  ];

  home.packages = with pkgs; [
    age
    sops
  ];
}
