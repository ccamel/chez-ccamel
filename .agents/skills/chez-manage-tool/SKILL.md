---
name: chez-manage-tool
description: Manage CLI and agentic or DevOps tools in chez-ccamel by choosing the correct Nix or Home Manager integration, wiring documentation metadata, and verifying both supported systems. Use when adding, configuring, moving, or removing a tool in this repository; do not use for version or hash-only updates of resources managed by scripts/update-resource.py.
---

# Manage a chez-ccamel tool

## Inputs

Establish the requested tool, its intended scope (`core`, `agentic`, `devops`, or one named host), whether it needs configuration, and the executable to use for a non-destructive smoke test.

Derive package availability, Home Manager options, and repository conventions from nixpkgs, Home Manager, and this repository. Ask only when scope is a genuine user preference.

## Workflow

1. Inspect existing changes and the nearest comparable integration before editing. Preserve unrelated work.
2. Route the request before choosing files:
   - A shared daily CLI with a Home Manager `programs.<tool>` option or plain package belongs in `nix-config/home/modules/cli.nix`.
   - Shared configuration requiring a separate source file or activation hook belongs in a dedicated `nix-config/home/modules/<tool>/` directory imported by `nix-config/home/common.nix`. Otherwise, keep it in `cli.nix`.
   - An agentic or DevOps development-shell tool belongs in one descriptor in `nix-config/toolboxes/agentic.nix` or `nix-config/toolboxes/devops.nix`.
   - Host-only behavior belongs in its owning `nix-config/hosts/forge/` or `nix-config/hosts/tinymac/` file, not the shared module graph.
   - When nixpkgs has no suitable package, add a focused `nix-config/packages/<tool>.nix`, call it through `pkgs.callPackage` in `nix-config/flake.nix`, and pass it through `toolboxArgs` to the descriptor that consumes it. Prefer an existing nixpkgs package or Home Manager option first.
3. Make a clean cutover: update every affected caller and remove obsolete configuration, metadata, and package paths.

## Documentation

Core public tools require an exact `{ name, description, url, visibility }` entry in the corresponding `*.readme.nix` metadata source.

User-facing toolbox entries carry the same `documentation` attribute. Support-only packages may omit it, as `terraform-ls` and `tflint` do.

Never hand-edit README rows between generated markers. Run `just generate-readme`, then verify with `just check-readme`.

## Verification

Support both `x86_64-linux` and `aarch64-darwin` explicitly. Evaluate the relevant Home Manager or toolbox configuration for both systems.

Run the requested executable from the relevant home configuration or `agentic`/`devops` development shell with `--version`, `--help`, or an equivalent non-destructive smoke check. Finish with `just check`.

## Guardrails

Do not use this skill for version-only or hash-only managed-resource updates; use `chez-update-resource` instead.

Keep repository skills out of Home Manager, OMP configuration, generated README tables, and toolbox metadata. They are discovered from the checkout, not installed as executable tools.
