{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets."git-mine-signing-key" = {
    sopsFile = ../../secrets/personal.yaml;
    mode = "0400";
  };

  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        source = ./git-mine-public.asc;
        trust = "ultimate";
      }
    ];
  };

  home.activation.importMineSigningKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! ${pkgs.gnupg}/bin/gpg --batch --list-secret-keys \
      97883AD24DB187825FEE2FF0CF349A84B43D3D51 >/dev/null 2>&1; then
      ${pkgs.gnupg}/bin/gpg --batch --import \
        "${config.sops.secrets."git-mine-signing-key".path}"
    fi
  '';
}
