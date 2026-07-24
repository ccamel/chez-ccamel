{ pkgs, ... }:
{
  programs = {
    delta = {
      enable = true;
      enableGitIntegration = true;
    };

    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        pull.ff = "only";
        push.autoSetupRemote = true;
        tig.bind.status = "+ !git commit --amend";
      };
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = "vim";
        prompt = "enabled";
        pager = "bat";
        aliases.co = "pr checkout";
      };
    };
  };

  home.packages = with pkgs; [
    tig
  ];
}
