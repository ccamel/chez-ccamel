{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets."git-corp-bundle" = {
    sopsFile = ../../secrets/git-corp-bundle;
    format = "binary";
    mode = "0400";
  };

  home.activation.importCorpBundle = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    corpDir="${config.xdg.configHome}/git/corp"
    mkdir -p "${config.xdg.configHome}/git"
    tmpDir="$(${pkgs.coreutils}/bin/mktemp -d "${config.xdg.configHome}/git/corp.XXXXXX")"
    chmod 0700 "$tmpDir"
    ${pkgs.gnutar}/bin/tar -xzf "${config.sops.secrets."git-corp-bundle".path}" -C "$tmpDir"
    if [ ! -f "$tmpDir/config" ]; then
      echo "git-corp-bundle: missing config after extraction" >&2
      rm -rf "$tmpDir"
      exit 1
    fi
    chmod -R u+rwX,go-rwx "$tmpDir"
    rm -rf "$corpDir"
    mv "$tmpDir" "$corpDir"
  '';

  programs.git.includes = [
    {
      path = "${config.xdg.configHome}/git/corp/config";
    }
  ];
}
