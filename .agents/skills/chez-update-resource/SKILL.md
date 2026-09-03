---
name: chez-update-resource
description: Update the latest chez-ccamel resources managed by scripts/update-resource.py and repair their upstream mappings when release metadata changes. Use for managed resource updates or updater failures; do not use for historical pins or ordinary nixpkgs input updates.
---

# Update a managed chez-ccamel resource

## Inputs

Require one supported resource name. Read `RESOURCES` in `scripts/update-resource.py` and the target Nix package before changing anything.

Accept only resource names in `RESOURCES`. This skill handles latest releases, branch tips, registry metadata, and native fixed-output hashes; it does not update ordinary flake inputs.

## Workflow

1. Inspect existing changes and preserve unrelated work.
2. From the repository root, run `just update-resource <resource>`. Do not use the argument-less recipe unless the request explicitly covers all resources.
3. Never hand-edit assignments immediately following `# managed by update-resource`.
4. Treat the script's printed diff, `just fmt`, and targeted Nix build as part of the command result. Review them before continuing.

`GitHubReleaseResource` updates the version and hashes in `SYSTEMS` order. Source archives resolve a revision and Nix-derived unpacked hash; npm resources retain registry integrity; QMD refreshes only the current system hash.

## Failure handling

Do not prescribe manual hash edits. When the latest tag or asset contract changes, update the corresponding `RESOURCES` entry. Extend the narrow resource dataclass or collection logic only when the existing `GitHubReleaseResource` or `FetchUrlResource` shape cannot represent the new upstream.

When package markers or call arguments intentionally change, update the marker/build-expression contract in the script and target package together. Preserve explicit `UpdateError` failures, rerun the named update, and verify the resulting package.

## Verification

Verify the resulting target package after the update command completes, then run `just check` before completion.

## Guardrails

Classify a historical-version request as outside this latest-release skill and return it to the normal repository workflow rather than silently applying latest metadata.

Keep network, release lookup, asset selection, hash computation, replacement, formatting, and build logic in `scripts/update-resource.py`; this skill is instruction-only.
