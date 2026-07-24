{ inputs, ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    primaryUser = "chris";
    stateVersion = 6;
  };

  users.users.chris.home = "/Users/chris";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.zsh.enable = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "none";
      upgrade = false;
    };
    casks = [ "ghostty" ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "hm-pre-nix";
    users.chris = {
      imports = [ ./home.nix ];
    };
  };
}
