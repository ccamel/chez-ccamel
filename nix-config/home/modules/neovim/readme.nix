{ pkgs }:
[
  {
    name = "Neovim";
    inherit (pkgs.neovim) version;
    description = "Editor built around LazyVim.";
    url = "https://neovim.io/";
    visibility = "public";
  }
]
