{ pkgs }:
let
  extensions = import ./omp-extensions.nix;
  # HerdR's OMP integration v10 leaves its lifecycle authority active on exit.
  # Lig keeps the outer foreground group alive, so clear that authority explicitly.
  herdrRelease = pkgs.writeText "herdr-omp-release.ts" ''
    import net from "node:net";
    import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

    export default function (pi: ExtensionAPI) {
      const { HERDR_ENV, HERDR_PANE_ID, HERDR_SOCKET_PATH, OMPCODE } = process.env;
      if (HERDR_ENV !== "1" || !HERDR_PANE_ID || !HERDR_SOCKET_PATH || OMPCODE === "1") return;

      pi.on("session_shutdown", async (_event, ctx) => {
        if (!ctx.hasUI) return;
        await new Promise<void>((resolve) => {
          const socket = net.createConnection(HERDR_SOCKET_PATH);
          socket.setTimeout(1000, () => socket.destroy());
          socket.once("error", () => socket.destroy());
          socket.once("data", () => socket.destroy());
          socket.once("close", () => resolve());
          socket.once("connect", () => socket.write(JSON.stringify({
            id: "omp-shutdown",
            method: "pane.clear_agent_authority",
            params: {
              pane_id: HERDR_PANE_ID,
              source: "herdr:omp",
              seq: Date.now() * 1000,
            },
          }) + "\n"));
        });
      });
    }
  '';
in
{
  extensions = map (extension: "${extension.package { inherit pkgs; }}") extensions ++ [
    "${herdrRelease}"
  ];
  symbolPreset = "nerd";
  statusLine.preset = "nerd";
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
  github.enabled = true;
  systemPromptSwitch.promptOnStartup = false;
}
