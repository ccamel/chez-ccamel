---
name: chez-nix
description: >
  Repository conventions for changing and debugging existing Nix configuration:
  flakes, NixOS, nix-darwin, Home Manager, and development-shell wiring. Use
  when the task modifies `nix-config`, evaluates a flake, or diagnoses a Nix
  build or evaluation failure. Do not use to add or move tools, or to update
  managed resources.
---

# Work on chez-ccamel Nix

## Scope

This skill covers Nix wiring and troubleshooting. Tool-specific integration and
managed resource updates are outside its scope.

The repository supports `x86_64-linux` (`forge`) and `aarch64-darwin`
(`tinymac`). Keep host-only behavior in `nix-config/hosts/<host>/`, shared user
configuration under `nix-config/home/`, and development-shell composition under
`nix-config/toolboxes/`.

## Before editing

1. Read the closest existing module and its caller.
2. Preserve unrelated changes.
3. Prefer an existing module option or repository pattern over a new abstraction,
   input, overlay, activation script, or service.

## Conventions

- Keep inputs pinned in `nix-config/flake.lock`; do not use channels, `nix-env`,
  or impure fetches.
- Make transitive inputs follow the primary `nixpkgs` input unless compatibility
  requires an independent pin; document that exception beside the input.
- Keep supported systems explicit and use the existing `forEachSystem` helper
  for per-system flake outputs.
- Prefer NixOS, nix-darwin, and Home Manager options over activation scripts,
  raw launchd plists, or hand-written systemd units.
- Do not change `system.stateVersion` or `home.stateVersion` without an explicit
  migration requirement.
- Do not change unrelated Homebrew activation policy while editing Darwin config.

## Gotcha

- On the pinned nix-darwin release, schedule collection with `nix.gc.interval`;
  `nix.gc.dates` is removed.

## Verification

1. Run `just check-fmt` and `nix run --inputs-from ./nix-config nixpkgs#statix -- check nix-config` after editing Nix.
2. From `nix-config`, run `nix flake check --no-build .` for native evaluation.
3. Evaluate the exact `nixosConfigurations.forge` or
   `darwinConfigurations.tinymac` attribute when cross-system inputs are
   unavailable.
4. Build the changed host on its matching platform; CI covers both host
   toplevels.
5. For a changed shell, service, or configuration output, run its smallest
   non-destructive smoke check.

If a cross-system check cannot run locally, report the exact failure rather than
weakening the configuration or skipping native evaluation.
