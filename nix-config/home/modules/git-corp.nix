{ config, ... }:
{
  sops.secrets."git-corp-config" = {
    sopsFile = ../../secrets/git-corp.yaml;
    key = "config";
    mode = "0400";
  };

  programs.git.includes = [
    {
      inherit (config.sops.secrets."git-corp-config") path;
    }
  ];
}
