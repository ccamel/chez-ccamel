{ pkgs }:
[
  {
    name = "Zsh";
    inherit (pkgs.zsh) version;
    description = "Interactive shell with vi-mode editing.";
    url = "https://www.zsh.org/";
    visibility = "public";
  }
]
