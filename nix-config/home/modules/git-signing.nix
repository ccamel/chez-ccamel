{
  config,
  lib,
  pkgs,
  ...
}:
let
  sshAgentSocket =
    if pkgs.stdenv.isDarwin then
      "$(${lib.getExe pkgs.getconf} DARWIN_USER_TEMP_DIR)/${config.services.ssh-agent.socket}"
    else
      "$XDG_RUNTIME_DIR/${config.services.ssh-agent.socket}";
in
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
    pinentry.package = pkgs.pinentry-tty;
    extraConfig = "allow-loopback-pinentry";
  };

  services.ssh-agent.enable = true;

  programs.zsh.initContent = lib.mkAfter ''
    if [ -n "$SSH_AUTH_SOCK" ] && [ "$SSH_AUTH_SOCK" -ef "$(
      ${pkgs.gnupg}/bin/gpgconf --list-dirs agent-ssh-socket
    )" ]; then
      export SSH_AUTH_SOCK=${sshAgentSocket}
    fi
  '';

  home.activation.importMineSigningKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! ${pkgs.gnupg}/bin/gpg --batch --list-secret-keys \
      97883AD24DB187825FEE2FF0CF349A84B43D3D51 >/dev/null 2>&1; then
      ${pkgs.gnupg}/bin/gpg --batch --import \
        "${config.sops.secrets."git-mine-signing-key".path}"
    fi
  '';
}
