{ pkgs }:
[
  {
    name = "Atuin";
    inherit (pkgs.atuin) version;
    description = "Searchable shell history.";
    url = "https://atuin.sh/";
    visibility = "public";
  }
]
