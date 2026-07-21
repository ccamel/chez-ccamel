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
}
