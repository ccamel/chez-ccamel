{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ../../home/common.nix
    ../../home/modules/sops.nix
    ../../home/modules/git-signing.nix
    ../../home/modules/git-mine.nix
    inputs.nix-index-database.homeModules.nix-index
    ../../home/modules/ghostty
  ];

  home = {
    username = "chris";
    homeDirectory = "/Users/chris";
    stateVersion = "25.11";
    sessionVariables.CHEZ_CCAMEL_ROOT = "/Users/chris/src/mine/chez-ccamel";
  };

  xdg.enable = true;

  home.packages = [ config.programs.home-manager.package ];

  # portable-pty starts test processes in HOME, which is absent in the Nix sandbox.
  programs.lig.package =
    inputs.lig.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
      (old: {
        preCheck = (old.preCheck or "") + ''
          export HOME="$TMPDIR"
        '';
      });

  home.file.".gitconfig".source = config.xdg.configFile."git/config".source;

}
