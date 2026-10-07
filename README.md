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
| [Atuin v18.10.0](https://atuin.sh/) | Searchable shell history. |
| [bat v0.26.1](https://github.com/sharkdp/bat) | Cat clone with syntax highlighting. |
| [Btop v1.4.5](https://github.com/aristocratos/btop) | Resource monitor for the terminal. |
| [curl v8.20.0](https://curl.se/) | Command-line HTTP client. |
| [direnv v2.37.1](https://direnv.net/) | Directory-scoped environment variables. |
| [Dust v1.2.4](https://github.com/bootandy/dust) | Intuitive disk usage analyzer. |
| [ExifTool v13.59](https://exiftool.org/) | Command-line toolkit for metadata manipulation. |
| [eza v0.23.4](https://eza.rocks/) | Modern replacement for ls. |
| [fd v10.3.0](https://github.com/sharkdp/fd) | Fast, user-friendly file finder. |
| [fzf v0.67.0](https://github.com/junegunn/fzf) | Fuzzy finder for the command line. |
| [Ghostty v1.3.1](https://ghostty.org/) | Terminal emulator. |
| [Git v2.51.2](https://git-scm.com/) | Distributed version control system. |
| [GitHub CLI v2.93.0](https://cli.github.com/) | GitHub's command-line interface. |
| [Glow v2.1.1](https://github.com/charmbracelet/glow) | Terminal markdown reader. |
| [ImageMagick v7.1.2-23](https://imagemagick.org/) | Command-line toolkit for image manipulation. |
| [jq v1.8.1](https://jqlang.org/) | Command-line JSON processor. |
| [lazydocker v0.24.2](https://github.com/jesseduffield/lazydocker) | Terminal UI for Docker. |
| [Neovim v0.11.7](https://neovim.io/) | Editor built around LazyVim. |
| [poppler-utils v25.10.0](https://poppler.freedesktop.org/) | Command-line utilities for PDF inspection and extraction. |
| [Python v3.13.12](https://www.python.org/) | General-purpose programming language. |
| [qpdf v12.2.0](https://qpdf.sourceforge.io/) | Command-line tools for PDF transformation and inspection. |
| [ripgrep v15.1.0](https://github.com/BurntSushi/ripgrep) | Fast recursive text search. |
| [Starship v1.24.2](https://starship.rs/) | Cross-shell prompt. |
| [Tig v2.6.0](https://jonas.github.io/tig/) | Text-mode interface for Git. |
| [yq v4.50.1](https://github.com/mikefarah/yq) | Portable command-line YAML processor. |
| [zoxide v0.9.9](https://github.com/ajeetdsouza/zoxide) | Smarter directory navigation. |
| [Zsh v5.9](https://www.zsh.org/) | Interactive shell with vi-mode editing. |
<!-- END_GENERATED_CORE -->

### Agentic development

<!-- BEGIN_GENERATED_AGENTIC -->
My terminal-native playground for building software alongside a small herd of AI agents.

#### Harnesses

The control plane for agent sessions, tool access, configuration, and observable work.

| Component | Role |
| --- | --- |
| [agtx v1.0.6](https://github.com/fynnfluegge/agtx) | Terminal-native development environment for coding agents. |
| [HerdR v0.9.3](https://github.com/ogulcancelik/herdr) | Terminal-native multiplexer for AI coding agents. |
| [OMP v18.8.0](https://github.com/can1357/oh-my-pi) | Terminal-first AI coding agent. |

#### Coding agents

The interchangeable specialist CLIs run within the wider workflow.

| Component | Role |
| --- | --- |
| [Antigravity CLI v1.2.16](https://antigravity.google/product/antigravity-cli) | Google's terminal-native agentic coding CLI. |
| [Claude Code v2.1.140](https://docs.anthropic.com/en/docs/claude-code/overview) | Anthropic's agentic coding CLI. |
| [Codex v0.160.0](https://openai.com/codex/) | OpenAI coding agent. |
| [GitHub Copilot CLI v1.0.88](https://github.com/github/copilot-cli) | GitHub Copilot coding agent. |

#### Extensions and integrations

Harness capabilities installed declaratively with the toolbox.

| Component | Role |
| --- | --- |
| [HerdR Annotate v0.8.0-unstable-2026-09-29](https://github.com/plannotator/herdr-annotate) | Annotate terminal selections and copy them as agent context. |
| [HerdR Remote v0.8.0](https://github.com/dcolinmorgan/herdr-remote) | Monitor and approve HerdR agents from a phone, menu bar, or Telegram. |
| [OMP Undo/Redo v1.6.5](https://github.com/Baylar55/omp-undo-redo) | Session-navigation history controls for OMP. |
| [Ponytail v4.13.0](https://github.com/DietrichGebert/ponytail) | Opinionated minimalism modes and skills for OMP. |
| [shepherdr v0.1.0-unstable-2026-07-24](https://github.com/afogel/shepherdr) | Herdr plugin for auditable delegated coding agents. |
| [System Prompt Switch v0.10.0](https://github.com/plantaeart/system-prompt-switch) | Session-scoped system prompt selection for OMP. |

#### Operating tools

Tools for coordination, context, inspection, and efficient terminal output.

| Component | Role |
| --- | --- |
| [APM v0.30.0](https://github.com/microsoft/apm) | Dependency manager for AI agent configuration. |
| [Herd](https://gist.github.com/ccamel/46a021372c326f31fdb3b5a55b238214) | Coordinate multiple AI coding agents. |
| [Livediff v3.4.0](https://github.com/SoCkEt7/Livediff) | Watch file diffs live in the terminal. |
| [QMD v2.8.3](https://github.com/tobi/qmd) | On-device search engine for markdown notes, meeting transcripts, and knowledge bases. |
| [rtk v0.51.0](https://github.com/rtk-ai/rtk) | Command-output optimizer. |
<!-- END_GENERATED_AGENTIC -->

### DevOps

Infrastructure and platform engineering.

<!-- BEGIN_GENERATED_DEVOPS -->
| Tool | Description |
| --- | --- |
| [dnsutils v9.20.23](https://www.isc.org/bind/) | DNS tools like dig and nslookup. |
| [gcloud v537.0.0](https://cloud.google.com/sdk/gcloud) | Google Cloud command-line interface. |
| [Helm v3.19.1](https://helm.sh/) | Kubernetes package manager. |
| [Helmfile v1.1.9](https://helmfile.readthedocs.io/) | Declarative Helm chart deployment tool. |
| [k9s v0.50.16](https://k9scli.io/) | Terminal UI for Kubernetes. |
| [kubectl v1.34.3](https://kubernetes.io/docs/reference/kubectl/) | Kubernetes command-line tool. |
| [Kustomize v5.8.0](https://kustomize.io/) | Kubernetes configuration customization tool. |
| [Terraform v1.14.0](https://www.terraform.io/) | Infrastructure as code tool. |
| [Terragrunt v0.93.8](https://terragrunt.gruntwork.io/) | Terraform orchestration and DRY configuration tool. |
| [Trivy v0.66.0](https://trivy.dev/) | Cloud-native vulnerability and misconfiguration scanner. |
| [whois v5.6.5](https://github.com/rfc1036/whois) | Client for the WHOIS directory service. |
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
