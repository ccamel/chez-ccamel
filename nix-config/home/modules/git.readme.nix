{ pkgs }:
[
  {
    name = "Git";
    inherit (pkgs.git) version;
    description = "Distributed version control system.";
    url = "https://git-scm.com/";
    visibility = "public";
  }
  {
    name = "GitHub CLI";
    inherit (pkgs.gh) version;
    description = "GitHub's command-line interface.";
    url = "https://cli.github.com/";
    visibility = "public";
  }
  {
    name = "Tig";
    inherit (pkgs.tig) version;
    description = "Text-mode interface for Git.";
    url = "https://jonas.github.io/tig/";
    visibility = "public";
  }
]
