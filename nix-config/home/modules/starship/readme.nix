{ pkgs }:
[
  {
    name = "Starship";
    inherit (pkgs.starship) version;
    description = "Cross-shell prompt.";
    url = "https://starship.rs/";
    visibility = "public";
  }
]
