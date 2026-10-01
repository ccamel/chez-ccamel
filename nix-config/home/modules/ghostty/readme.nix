{ pkgs }:
[
  {
    name = "Ghostty";
    inherit (pkgs.ghostty) version;
    description = "Terminal emulator.";
    url = "https://ghostty.org/";
    visibility = "public";
  }
]
