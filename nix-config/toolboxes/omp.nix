{ pkgs }:
let
  ompUndoRedo = pkgs.callPackage ../packages/omp-undo-redo.nix { };
  ponytail = pkgs.callPackage ../packages/ponytail.nix { };
in
{
  extensions = [
    "${ompUndoRedo}"
    "${ponytail}"
  ];
  symbolPreset = "nerd";
  theme.dark = "titanium";
  setupVersion = 2;
  modelRoles = {
    advisor = "openai-codex/gpt-5.6-sol:xhigh";
    designer = "openai-codex/gpt-5.6-terra:max";
    smol = "openai-codex/gpt-5.6-luna:max";
    task = "openai-codex/gpt-5.6-terra:max";
    plan = "openai-codex/gpt-5.6-sol:xhigh";
    vision = "openai-codex/gpt-5.6-terra:xhigh";
    commit = "openai-codex/gpt-5.6-terra:high";
    tiny = "openai-codex/gpt-5.6-luna:max";
    slow = "openai-codex/gpt-5.6-sol:xhigh";
    default = "openai-codex/gpt-5.6-terra:high";
  };
  terminal.showProgress = true;
  display = {
    smoothStreaming = true;
    shimmer = "classic";
    showTokenUsage = true;
  };
  composer.shape = "box";
  task.agentModelOverrides = {
    "code-architect" = "openai-codex/gpt-5.6-sol";
    "code-explorer" = "openai-codex/gpt-5.6-luna";
    "code-reviewer" = "openai-codex/gpt-5.6-sol";
  };
  dev.autoqaConsent = "denied";
}
