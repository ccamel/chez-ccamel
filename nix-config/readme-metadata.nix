let
  toolboxes = {
    agentic = import ./toolboxes/agentic.nix;
    devops = import ./toolboxes/devops.nix;
  };

  documentationFor =
    descriptors:
    map (descriptor: descriptor.documentation) (
      builtins.filter (descriptor: descriptor ? documentation) descriptors
    );
in
{
  core = builtins.concatLists [
    (import ./home/modules/cli.readme.nix)
    (import ./home/modules/git.readme.nix)
    (import ./home/modules/neovim/readme.nix)
    (import ./home/modules/zsh/readme.nix)
    (import ./home/modules/atuin/readme.nix)
    (import ./home/modules/starship/readme.nix)
    (import ./home/modules/ghostty/readme.nix)
  ];
  agentic = documentationFor toolboxes.agentic;
  devops = documentationFor toolboxes.devops;
}
