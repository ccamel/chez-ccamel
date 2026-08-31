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

  documentationForGroup =
    group: descriptors:
    documentationFor (
      builtins.filter (descriptor: (descriptor.readmeGroup or null) == group) descriptors
    );

  agenticToolbox = toolboxes.agentic ++ (import ./toolboxes/omp-extensions.nix);
  agenticGroups = [
    {
      name = "Harnesses";
      description = "The control plane for agent sessions, tool access, configuration, and observable work.";
      items = documentationForGroup "Harnesses" agenticToolbox;
    }
    {
      name = "Coding agents";
      description = "The interchangeable specialist CLIs run within the wider workflow.";
      items = documentationForGroup "Coding agents" agenticToolbox;
    }
    {
      name = "Extensions and integrations";
      description = "Harness capabilities installed declaratively with the toolbox.";
      items = documentationForGroup "Extensions and integrations" agenticToolbox;
    }
    {
      name = "Operating tools";
      description = "Tools for coordination, context, inspection, and efficient terminal output.";
      items = documentationForGroup "Operating tools" agenticToolbox;
    }
  ];
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
  agentic = {
    description = "My terminal-native playground for building software alongside a small herd of AI agents.";
    groups = agenticGroups;
  };
  devops = documentationFor toolboxes.devops;
}
