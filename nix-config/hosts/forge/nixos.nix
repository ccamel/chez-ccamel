{ inputs, pkgs, ... }:
{
  wsl.enable = true;
  wsl.defaultUser = "chris";

  networking.hostName = "forge";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.zsh.enable = true;

  users.users.chris = {
    isNormalUser = true;
    home = "/home/chris";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
    users.chris = {
      imports = [ ./home.nix ];
    };
  };

  system.stateVersion = "25.11";
}
