{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      pull.ff = "only";
      push.autoSetupRemote = true;
    };
  };
}
