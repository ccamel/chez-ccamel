{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets."git-mine-signing-key" = {
    sopsFile = ../../secrets/git-mine.yaml;
    mode = "0400";
  };

  programs.gpg = {
    enable = true;
    settings.pinentry-mode = "loopback";
    publicKeys = [
      {
        source = ./git-mine-public.asc;
        trust = "ultimate";
      }
    ];
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtlSsh = 3600;
    maxCacheTtlSsh = 3600;
    pinentry.package = pkgs.pinentry-tty;
    extraConfig = "allow-loopback-pinentry";
  };

  home.activation.importMineSigningKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! ${pkgs.gnupg}/bin/gpg --batch --list-secret-keys \
      97883AD24DB187825FEE2FF0CF349A84B43D3D51 >/dev/null 2>&1; then
      ${pkgs.gnupg}/bin/gpg --batch --import \
        "${config.sops.secrets."git-mine-signing-key".path}"
    fi
  '';
}
