set shell := ["bash", "-euo", "pipefail", "-c"]
# Show available recipes without changing the system.
default:
    @just --list


# Switch the selected host configuration.
switch host=`hostname -s`:
    case "{{host}}" in forge) sudo nixos-rebuild switch --flake ./nix-config#forge ;; tinymac) sudo darwin-rebuild switch --flake ./nix-config#tinymac ;; *) echo "invalid host '{{host}}'; expected forge or tinymac" >&2; exit 1 ;; esac

# Check formatting of tracked Nix files.
check-fmt:
    git ls-files -z -- '*.nix' | xargs -0 nix run --inputs-from ./nix-config nixpkgs#nixfmt-rfc-style -- --check

# Check formatting and linting of tracked Lua files.
check-lua:
    git ls-files -z -- '*.lua' | xargs -0 nix run --inputs-from ./nix-config nixpkgs#stylua -- --check
    git ls-files -z -- '*.lua' | xargs -0 nix run --inputs-from ./nix-config nixpkgs#lua51Packages.luacheck --

# Verify both tracked secrets decrypt successfully.
check-secrets:
    cd nix-config && sops --decrypt secrets/git-mine.yaml > /dev/null
    cd nix-config && sops --decrypt --input-type binary --output-type binary secrets/git-corp-bundle > /dev/null

# Run repository checks; secret validation is explicit via check-secrets.
check: check-fmt check-lua
    cd nix-config && nix flake check . && nix run --inputs-from . nixpkgs#statix -- check .

# Format tracked Nix files.
fmt:
    git ls-files -z -- '*.nix' | xargs -0 nix run --inputs-from ./nix-config nixpkgs#nixfmt-rfc-style --
    git ls-files -z -- '*.lua' | xargs -0 nix run --inputs-from ./nix-config nixpkgs#stylua --

# Update all flake inputs.
update:
    nix flake update --flake ./nix-config

# Update one flake input.
update-input input:
    nix flake update --flake ./nix-config "{{input}}"

# Show resolved flake metadata.
metadata:
    nix flake metadata ./nix-config

# Edit one supported secret.
edit-secret secret:
    case "{{secret}}" in git-mine.yaml) cd nix-config && sops secrets/git-mine.yaml ;; git-corp-bundle) cd nix-config && sops --input-type binary --output-type binary secrets/git-corp-bundle ;; *) echo "invalid secret '{{secret}}'; expected git-mine.yaml or git-corp-bundle" >&2; exit 1 ;; esac

# Remove ignored build artifacts.
clean:
    git clean -fdX -- ':(glob)**/result' ':(glob)**/result-*' ':(glob)**/target' ':(glob)**/.direnv' ':(glob)**/.DS_Store'

# Collect currently unused Nix store paths.
gc:
    nix-collect-garbage

# Delete all old Nix generations.
gc-old:
    sudo nix-collect-garbage -d
