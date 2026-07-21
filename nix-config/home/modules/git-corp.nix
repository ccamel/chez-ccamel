{ config, ... }:
let
  secretFile = ../../secrets/corp.yaml;
in
{
  sops = {
    defaultSopsFile = secretFile;
    secrets."git-corp-config".mode = "0400";
  };

  programs.git.includes = [
    {
      condition = "gitdir:${config.home.homeDirectory}/src/corp/**";
      path = config.sops.secrets."git-corp-config".path;
    }
  ];
}
