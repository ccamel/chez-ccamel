{
  inputs,
  kdbx,
  pkgs,
  ...
}:
{
  wsl = {
    enable = true;
    defaultUser = "chris";
    interop.register = true;
  };
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  networking.hostName = "forge";
  security.pki.certificateFiles = [ ../../assets/zscaler-root-ca.pem ];

  environment = {
    systemPackages = [ pkgs.xdg-utils ];

    sessionVariables = {
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
      NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
      REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
      CURL_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
      PYTHONPATH = "/etc/python";
    };

    # shortcut: relaxes Python 3.13+ VERIFY_X509_STRICT for Zscaler root CA lacking critical Basic Constraints, remove when corporate CA is reissued compliant with RFC 5280
    etc."python/sitecustomize.py".text = ''
      import ssl

      if hasattr(ssl, "VERIFY_X509_STRICT"):
          _orig_get = ssl.SSLContext.verify_flags.__get__
          _orig_set = ssl.SSLContext.verify_flags.__set__

          def _set(self, val):
              val &= ~ssl.VERIFY_X509_STRICT
              return _orig_set(self, val)

          ssl.SSLContext.verify_flags = property(_orig_get, _set)
    '';
  };

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

  };

  users.users.chris = {
    isNormalUser = true;
    home = "/home/chris";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "docker"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs kdbx; };
    sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
    users.chris = {
      imports = [ ./home.nix ];
    };
  };

  system.stateVersion = "25.11";
}
