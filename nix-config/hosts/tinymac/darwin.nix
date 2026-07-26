{ inputs, pkgs, ... }:
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    primaryUser = "chris";
    stateVersion = 6;
  };

  users.users.chris.home = "/Users/chris";

  fonts.packages = [ pkgs.nerd-fonts.proggy-clean-tt ];

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
    sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
    users.chris = {
      imports = [ ./home.nix ];
    };
  };
}
