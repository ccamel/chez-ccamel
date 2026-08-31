[
  {
    package = { codex, ... }: codex;
    readmeGroup = "Coding agents";
    documentation = {
      name = "Codex";
      description = "OpenAI coding agent.";
      url = "https://openai.com/codex/";
      visibility = "public";
    };
  }
  {
    package = { pkgs, ... }: pkgs.claude-code;
    readmeGroup = "Coding agents";
    documentation = {
      name = "Claude Code";
      description = "Anthropic's agentic coding CLI.";
      url = "https://docs.anthropic.com/en/docs/claude-code/overview";
      visibility = "public";
    };
  }
  {
    package = { antigravityCli, ... }: antigravityCli;
    readmeGroup = "Coding agents";
    documentation = {
      name = "Antigravity CLI";
      description = "Google's terminal-native agentic coding CLI.";
      url = "https://antigravity.google/product/antigravity-cli";
      visibility = "public";
    };
  }
  {
    package = { githubCopilotCli, ... }: githubCopilotCli;
    readmeGroup = "Coding agents";
    documentation = {
      name = "GitHub Copilot CLI";
      description = "GitHub Copilot coding agent.";
      url = "https://github.com/github/copilot-cli";
      visibility = "public";
    };
  }
  {
    package = { rtk, ... }: rtk;
    readmeGroup = "Operating tools";
    documentation = {
      name = "rtk";
      description = "Command-output optimizer.";
      url = "https://github.com/rtk-ai/rtk";
      visibility = "public";
    };
  }
  {
    package = { livediff, ... }: livediff;
    readmeGroup = "Operating tools";
    documentation = {
      name = "Livediff";
      description = "Watch file diffs live in the terminal.";
      url = "https://github.com/SoCkEt7/Livediff";
      visibility = "public";
    };
  }
  {
    package = { omp, ... }: omp;
    readmeGroup = "Harnesses";
    documentation = {
      name = "OMP";
      description = "Terminal-first AI coding agent.";
      url = "https://github.com/can1357/oh-my-pi";
      visibility = "public";
    };
  }
  {
    package =
      { pkgs, ... }:
      pkgs.vscode-langservers-extracted.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          cp json-language-features/server/dist/node/*.js \
            "$out/lib/extensions/json-language-features/server/dist/node/"
        '';
      });
  }
  {
    package = { pkgs, ... }: pkgs.yaml-language-server;
  }
  {
    package = { pkgs, ... }: pkgs.marksman;
  }
  {
    package = { qmd, ... }: qmd;
    readmeGroup = "Operating tools";
    documentation = {
      name = "QMD";
      description = "On-device search engine for markdown notes, meeting transcripts, and knowledge bases.";
      url = "https://github.com/tobi/qmd";
      visibility = "public";
    };
  }
  {
    package = { herdr, ... }: herdr;
    readmeGroup = "Harnesses";
    documentation = {
      name = "HerdR";
      description = "Terminal-native multiplexer for AI coding agents.";
      url = "https://github.com/ogulcancelik/herdr";
      visibility = "public";
    };
  }
  {
    package = { herdrAnnotate, ... }: herdrAnnotate;
    readmeGroup = "Extensions and integrations";
    documentation = {
      name = "HerdR Annotate";
      description = "Annotate terminal selections and copy them as agent context.";
      url = "https://github.com/plannotator/herdr-annotate";
      visibility = "public";
    };
  }
  {
    package = { shepherdr, ... }: shepherdr;
    readmeGroup = "Extensions and integrations";
    documentation = {
      name = "shepherdr";
      description = "Herdr plugin for auditable delegated coding agents.";
      url = "https://github.com/afogel/shepherdr";
      visibility = "public";
    };
  }
  {
    package = { herd, ... }: herd;
    readmeGroup = "Operating tools";
    documentation = {
      name = "Herd";
      description = "Coordinate multiple AI coding agents.";
      url = "https://gist.github.com/ccamel/46a021372c326f31fdb3b5a55b238214";
      visibility = "public";
    };
  }
]
