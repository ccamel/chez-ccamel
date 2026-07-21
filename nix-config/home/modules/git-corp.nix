{ config, ... }:
let
  secretFile = ../../secrets/corp.yaml;
in
{
  sops = {
    defaultSopsFile = secretFile;
    secrets."git-work-config".mode = "0400";
  };

  programs.git.includes = [
    {
      condition = "gitdir:${config.home.homeDirectory}/src/work/**";
      path = config.sops.secrets."git-work-config".path;
    }
  ];
}
