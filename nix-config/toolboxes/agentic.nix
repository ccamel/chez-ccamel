[
  {
    package = { pkgs, ... }: pkgs.codex;
    documentation = {
      name = "Codex";
      description = "OpenAI coding agent.";
      url = "https://openai.com/codex/";
      visibility = "public";
    };
  }
  {
    package = { pkgs, ... }: pkgs.gemini-cli;
    documentation = {
      name = "Gemini CLI";
      description = "Google AI coding agent.";
      url = "https://github.com/google-gemini/gemini-cli";
      visibility = "public";
    };
  }
  {
    package = { pkgs, ... }: pkgs.github-copilot-cli;
    documentation = {
      name = "GitHub Copilot CLI";
      description = "GitHub Copilot coding agent.";
      url = "https://github.com/github/copilot-cli";
      visibility = "public";
    };
  }
  {
    package = { rtk, ... }: rtk;
    documentation = {
      name = "rtk";
      description = "Command-output optimizer.";
      url = "https://github.com/rtk-ai/rtk";
      visibility = "public";
    };
  }
  {
    package = { livediff, ... }: livediff;
    documentation = {
      name = "Livediff";
      description = "Watch file diffs live in the terminal.";
      url = "https://github.com/SoCkEt7/Livediff";
      visibility = "public";
    };
  }
  {
    package = { omp, ... }: omp;
    documentation = {
      name = "OMP";
      description = "Terminal-first AI coding agent.";
      url = "https://github.com/can1357/oh-my-pi";
      visibility = "public";
    };
  }
  {
    package = { herdr, ... }: herdr;
    documentation = {
      name = "HerdR";
      description = "Terminal-native multiplexer for AI coding agents.";
      url = "https://github.com/ogulcancelik/herdr";
      visibility = "public";
    };
  }
  {
    package = { herd, ... }: herd;
    documentation = {
      name = "Herd";
      description = "Coordinate multiple AI coding agents.";
      url = "https://gist.github.com/ccamel/46a021372c326f31fdb3b5a55b238214";
      visibility = "public";
    };
  }
]
