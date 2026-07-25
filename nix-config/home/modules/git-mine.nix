{ config, ... }:
{
  xdg.configFile."git/mine".text = ''
    [user]
    	name = ccamel
    	email = camel.christophe@gmail.com
    	signingkey = 97883AD24DB187825FEE2FF0CF349A84B43D3D51
    [commit]
    	gpgsign = true
  '';

  programs.git.includes = [
    {
      condition = "gitdir:${config.home.homeDirectory}/src/mine/**";
      path = "${config.xdg.configHome}/git/mine";
    }
  ];
}
