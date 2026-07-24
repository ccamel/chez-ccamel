{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops = {
    defaultSopsFile = ../../secrets/corp.yaml;
    secrets."git-mine-signing-key".mode = "0400";
  };

  home.activation.importMineSigningKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! ${pkgs.gnupg}/bin/gpg --batch --list-secret-keys \
      97883AD24DB187825FEE2FF0CF349A84B43D3D51 >/dev/null 2>&1; then
      ${pkgs.gnupg}/bin/gpg --batch --import \
        "${config.sops.secrets."git-mine-signing-key".path}"
    fi
  '';
}
