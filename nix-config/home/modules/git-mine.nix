{ ... }:
{
  programs = {
    gpg = {
      enable = true;
      publicKeys = [
        {
          source = ./git-mine-public.asc;
          trust = "ultimate";
        }
      ];
    };

    git.settings = {
      user = {
        name = "ccamel";
        email = "camel.christophe@gmail.com";
        signingkey = "97883AD24DB187825FEE2FF0CF349A84B43D3D51";
      };
      commit.gpgsign = true;
    };
  };

}
