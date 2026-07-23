{ config, ... }:
{
  imports = [
    ../../home/common.nix
    ../../home/modules/sops.nix
    ../../home/modules/git-mine.nix
    ../../home/modules/git-corp.nix
  ];

  home = {
    username = "chris";
    homeDirectory = "/home/chris";
    stateVersion = "25.11";
  };

  xdg.enable = true;

  home.file.".zscaler-root-ca.pem".source = ../../assets/zscaler-root-ca.pem;

  home.sessionVariables = {
    SSL_CERT_FILE = "${config.home.homeDirectory}/.zscaler-root-ca.pem";
  };
}
