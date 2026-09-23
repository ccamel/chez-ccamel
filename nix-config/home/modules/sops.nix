{
  config,
  inputs,
  pkgs,
  ...
}:
{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFormat = "yaml";
    package = (pkgs.callPackage inputs.sops-nix { }).sops-install-secrets.override {
      buildGoModule = pkgs.buildGo126Module;
    };
  };
}
