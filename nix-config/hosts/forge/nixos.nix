{ inputs, pkgs, ... }:
{
  wsl.enable = true;
  wsl.defaultUser = "chris";

  networking.hostName = "forge";
  security.pki.certificateFiles = [ ../../assets/zscaler-root-ca.pem ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs = {
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 14d --keep 5";
      };
    };

    zsh.enable = true;
    nix-ld.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      settings = {
        default-cache-ttl-ssh = 3600;
        max-cache-ttl-ssh = 3600;
      };
      pinentryPackage = pkgs.pinentry-tty;
    };
  };

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
