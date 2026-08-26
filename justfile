set shell := ["bash", "-euo", "pipefail", "-c"]
# Show available recipes without changing the system.
default:
    @just --list


# Switch the selected host configuration.
switch host=`hostname -s`:
    case "{{host}}" in forge) sudo nixos-rebuild switch --flake ./nix-config#forge ;; tinymac) sudo darwin-rebuild switch --flake ./nix-config#tinymac ;; *) echo "invalid host '{{host}}'; expected forge or tinymac" >&2; exit 1 ;; esac

# Check formatting of tracked Nix files.
check-fmt:
    git ls-files -z -- '*.nix' | while IFS= read -r -d '' file; do if test -f "$file"; then printf '%s\0' "$file"; fi; done | xargs -0 nix run --inputs-from ./nix-config nixpkgs#nixfmt-rfc-style -- --check

# Check formatting and linting of tracked Lua files.
check-lua:
    git ls-files -z -- '*.lua' | xargs -0 nix run --inputs-from ./nix-config nixpkgs#stylua -- --check
    git ls-files -z -- '*.lua' | xargs -0 nix run --inputs-from ./nix-config nixpkgs#lua51Packages.luacheck --

# Generate README tool tables from curated Nix metadata.
generate-readme:
    python3 scripts/generate-readme.py

# Verify generated README tool tables are current.
check-readme:
    python3 scripts/generate-readme.py --check

# Verify both tracked secrets decrypt successfully.
check-secrets:
    cd nix-config && sops --decrypt secrets/git-mine.yaml > /dev/null
    cd nix-config && sops --decrypt secrets/git-corp.yaml > /dev/null

# Run repository checks; secret validation is explicit via check-secrets.
check: check-fmt check-lua check-readme
    cd nix-config && nix flake check --all-systems . && nix run --inputs-from . nixpkgs#statix -- check .

# Format tracked Nix files.
fmt:
    git ls-files -z -- '*.nix' | while IFS= read -r -d '' file; do if test -f "$file"; then printf '%s\0' "$file"; fi; done | xargs -0 nix run --inputs-from ./nix-config nixpkgs#nixfmt-rfc-style --
    git ls-files -z -- '*.lua' | xargs -0 nix run --inputs-from ./nix-config nixpkgs#stylua --

# Update all flake inputs and managed binary resources.
update:
    just update-input
    just update-resource

# Update all flake inputs, or one when specified.
update-input input='':
    if test -n "{{input}}"; then nix flake update --flake ./nix-config "{{input}}"; else nix flake update --flake ./nix-config; fi

# Update all managed binary resources, or one when specified.
update-resource resource='':
    if test -n "{{resource}}"; then python3 scripts/update-resource.py "{{resource}}"; else for resource in omp herdr herd; do python3 scripts/update-resource.py "$resource"; done; fi

# Show resolved flake metadata.
metadata:
    nix flake metadata ./nix-config

# Edit one supported secret.
edit-secret secret:
    case "{{secret}}" in git-mine.yaml) cd nix-config && sops secrets/git-mine.yaml ;; git-corp.yaml) cd nix-config && sops secrets/git-corp.yaml ;; *) echo "invalid secret '{{secret}}'; expected git-mine.yaml or git-corp.yaml" >&2; exit 1 ;; esac

# Remove ignored build artifacts.
clean:
    git clean -fdX -- ':(glob)**/result' ':(glob)**/result-*' ':(glob)**/target' ':(glob)**/.direnv' ':(glob)**/.DS_Store'

# Collect currently unused Nix store paths.
gc:
    nix-collect-garbage

# Delete all old Nix generations.
gc-old:
    sudo nix-collect-garbage -d
