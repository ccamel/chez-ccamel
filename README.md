# chez-ccamel

> 🗄️ My machines. My tools. My environment.

<img src="./banner.webp" alt="banner" width="100%">

[![powered by Nix][powered-by-nix-badge]][powered-by-nix-link]
[![lint-nix-badge][lint-nix-badge]][lint-nix-workflow]
[![build-nix-badge][build-nix-badge]][build-nix-workflow]
[![commits-badge][commits-badge]][commits-page]

[powered-by-nix-badge]: https://img.shields.io/badge/Powered_by-Nix-5277C3.svg?style=for-the-badge&logo=nixos&logoColor=white
[powered-by-nix-link]: https://nixos.org/
[lint-nix-badge]: https://img.shields.io/github/actions/workflow/status/ccamel/chez-ccamel/lint-nix.yml?branch=main&label=Lint%20%2F%20Nix&style=for-the-badge&logo=github
[lint-nix-workflow]: https://github.com/ccamel/chez-ccamel/actions/workflows/lint-nix.yml
[build-nix-badge]: https://img.shields.io/github/actions/workflow/status/ccamel/chez-ccamel/build-nix.yml?branch=main&label=Build%20%2F%20Nix&style=for-the-badge&logo=github
[build-nix-workflow]: https://github.com/ccamel/chez-ccamel/actions/workflows/build-nix.yml
[commits-badge]: https://img.shields.io/github/last-commit/ccamel/chez-ccamel/main?style=for-the-badge&logo=github&color=%237dcfff
[commits-page]: https://github.com/ccamel/chez-ccamel/commits/main

If it's not here, it doesn't exist.

## What's inside

This repository is the environment I use every day. Everything is managed declaratively with [Nix][powered-by-nix-link], versioned, reproducible, and shared across my machines.

It intentionally stays small. Only the tools that shape my workflow belong here.

### Core

The terminal is home. These are the essential tools that define my everyday environment.

<!-- BEGIN_GENERATED_CORE -->
| Tool | Description |
| --- | --- |
| [Atuin](https://atuin.sh/) | Searchable shell history. |
| [bat](https://github.com/sharkdp/bat) | Cat clone with syntax highlighting. |
| [Btop](https://github.com/aristocratos/btop) | Resource monitor for the terminal. |
| [curl](https://curl.se/) | Command-line HTTP client. |
| [direnv](https://direnv.net/) | Directory-scoped environment variables. |
| [Dust](https://github.com/bootandy/dust) | Intuitive disk usage analyzer. |
| [eza](https://eza.rocks/) | Modern replacement for ls. |
| [fd](https://github.com/sharkdp/fd) | Fast, user-friendly file finder. |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder for the command line. |
| [Ghostty](https://ghostty.org/) | Terminal emulator. |
| [Git](https://git-scm.com/) | Distributed version control system. |
| [GitHub CLI](https://cli.github.com/) | GitHub's command-line interface. |
| [ImageMagick](https://imagemagick.org/) | Command-line toolkit for image manipulation. |
| [jq](https://jqlang.org/) | Command-line JSON processor. |
| [Neovim](https://neovim.io/) | Editor built around LazyVim. |
| [Python](https://www.python.org/) | General-purpose programming language. |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast recursive text search. |
| [Starship](https://starship.rs/) | Cross-shell prompt. |
| [Tig](https://jonas.github.io/tig/) | Text-mode interface for Git. |
| [yq](https://github.com/mikefarah/yq) | Portable command-line YAML processor. |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter directory navigation. |
| [Zsh](https://www.zsh.org/) | Interactive shell with vi-mode editing. |
<!-- END_GENERATED_CORE -->

### Agentic

The terminal-native tools I've chosen for agentic software engineering.

<!-- BEGIN_GENERATED_AGENTIC -->
| Tool | Description |
| --- | --- |
| [Codex](https://openai.com/codex/) | OpenAI coding agent. |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | Google AI coding agent. |
| [GitHub Copilot CLI](https://github.com/github/copilot-cli) | GitHub Copilot coding agent. |
| [Herd](https://gist.github.com/ccamel/46a021372c326f31fdb3b5a55b238214) | Coordinate multiple AI coding agents. |
| [HerdR](https://github.com/ogulcancelik/herdr) | Terminal-native multiplexer for AI coding agents. |
| [Livediff](https://github.com/SoCkEt7/Livediff) | Watch file diffs live in the terminal. |
| [OMP](https://github.com/can1357/oh-my-pi) | Terminal-first AI coding agent. |
| [rtk](https://github.com/rtk-ai/rtk) | Command-output optimizer. |
<!-- END_GENERATED_AGENTIC -->

### DevOps

Infrastructure and platform engineering.

<!-- BEGIN_GENERATED_DEVOPS -->
| Tool | Description |
| --- | --- |
| [Helm](https://helm.sh/) | Kubernetes package manager. |
| [Helmfile](https://helmfile.readthedocs.io/) | Declarative Helm chart deployment tool. |
| [k9s](https://k9scli.io/) | Terminal UI for Kubernetes. |
| [kubectl](https://kubernetes.io/docs/reference/kubectl/) | Kubernetes command-line tool. |
| [Kustomize](https://kustomize.io/) | Kubernetes configuration customization tool. |
| [Terraform](https://www.terraform.io/) | Infrastructure as code tool. |
| [Terragrunt](https://terragrunt.gruntwork.io/) | Terraform orchestration and DRY configuration tool. |
| [Trivy](https://trivy.dev/) | Cloud-native vulnerability and misconfiguration scanner. |
<!-- END_GENERATED_DEVOPS -->

## Bootstrap

Clone the repository using an ephemeral Git shell:

```sh
mkdir -p ~/src/mine
cd ~/src/mine

nix shell nixpkgs#git \
  --command git clone https://github.com/ccamel/chez-ccamel.git
```

Apply the system configuration:

```sh
sudo nixos-rebuild switch \
  --flake ~/src/mine/chez-ccamel/nix-config#forge
```

That's it.
