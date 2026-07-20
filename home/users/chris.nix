{ config, lib, ... }:
let
  secretFile = ../../secrets/users/chris.yaml;
  hasGitWorkConfig = builtins.pathExists secretFile;
in
{
  imports = [ ../profiles/core.nix ];

  home = {
    username = "chris";
    homeDirectory = "/home/chris";
    stateVersion = "25.11";
  };

  sops = lib.mkIf hasGitWorkConfig {
    age.keyFile = "/home/chris/.config/sops/age/keys.txt";
    defaultSopsFile = secretFile;
    defaultSopsFormat = "yaml";
    secrets."git-work-config".mode = "0400";
  };

  programs.git.includes = lib.optionals hasGitWorkConfig [
    {
      condition = "gitdir:/home/chris/src/work/**";
      path = config.sops.secrets."git-work-config".path;
    }
  ];
}
