{
  description = "NixOS and nix-darwin configurations for multiple hosts and environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-codex.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    omp.url = "github:can1357/oh-my-pi/v18.1.10";
    qmd.url = "github:tobi/qmd";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      forEachSystem = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      nixosConfigurations.forge = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          inputs.nixos-wsl.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          ./hosts/forge/nixos.nix
        ];
      };

      darwinConfigurations.tinymac = inputs.nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs; };
        modules = [
          inputs.home-manager.darwinModules.home-manager
          ./hosts/tinymac/darwin.nix
        ];
      };

      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
      lib.readmeDocumentation = import ./readme-metadata.nix;

      devShells = forEachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          codexPkgs = import inputs.nixpkgs-codex {
            inherit system;
            config.allowUnfree = true;
          };

          inherit (inputs.omp.packages.${system}) omp;
          qmd = pkgs.callPackage ./packages/qmd.nix {
            upstreamQmd = inputs.qmd.packages.${system}.qmd;
            src = inputs.qmd;
          };
          herdr = pkgs.callPackage ./packages/herdr.nix { };
          herdrAnnotate = pkgs.callPackage ./packages/herdr-annotate.nix { };
          herdrRemote = pkgs.callPackage ./packages/herdr-remote.nix { };
          shepherdr = pkgs.callPackage ./packages/shepherdr.nix { };
          herd = pkgs.callPackage ./packages/herd.nix { inherit herdr omp; };
          rtk = pkgs.callPackage ./packages/rtk.nix { };
          livediff = pkgs.callPackage ./packages/livediff.nix { };
          devopsToolbox = import ./toolboxes/devops.nix;
          agenticToolbox = import ./toolboxes/agentic.nix;
          toolboxArgs = {
            inherit
              pkgs
              omp
              herdr
              herdrAnnotate
              herdrRemote
              shepherdr
              herd
              rtk
              livediff
              qmd
              ;
            inherit (codexPkgs) codex;
            antigravityCli = codexPkgs.antigravity-cli;
            githubCopilotCli = codexPkgs.github-copilot-cli;
          };
          devopsPackages = map (descriptor: descriptor.package toolboxArgs) devopsToolbox;
          agenticPackages = map (descriptor: descriptor.package toolboxArgs) agenticToolbox;
          ompConfig = (pkgs.formats.yaml { }).generate "omp-config.yml" (
            import ./toolboxes/omp.nix { inherit pkgs; }
          );
          herdrShellHook = ''
            configHome="''${XDG_CONFIG_HOME:-$HOME/.config}"
            dataHome="''${XDG_DATA_HOME:-$HOME/.local/share}"
            ${pkgs.coreutils}/bin/install -Dm600 ${./toolboxes/herdr/config.toml} "$configHome/herdr/config.toml"
            ${pkgs.coreutils}/bin/install -Dm600 ${./toolboxes/herdr/herdr-plugin.toml} "$dataHome/herdr/plugins/shepherdr/herdr-plugin.toml"
            ${pkgs.coreutils}/bin/rm -rf "$dataHome/herdr/plugins/annotate"
            ${pkgs.coreutils}/bin/mkdir -p "$dataHome/herdr/plugins"
            ${pkgs.coreutils}/bin/cp -R ${herdrAnnotate} "$dataHome/herdr/plugins/annotate"
            ${pkgs.coreutils}/bin/chmod -R u+w "$dataHome/herdr/plugins/annotate"
            herdr plugin link "$dataHome/herdr/plugins/annotate" --enabled >/dev/null
            herdr plugin link "$dataHome/herdr/plugins/shepherdr" --enabled >/dev/null
            ${pkgs.coreutils}/bin/rm -rf "$configHome/herdr/plugins/github/herdr.push"
            ${pkgs.coreutils}/bin/rm -rf "$configHome/herdr/plugins/github/herdr-remote.relay"
            ${pkgs.coreutils}/bin/rm -rf "$dataHome/herdr/plugins/herdr-push"
            ${pkgs.coreutils}/bin/rm -rf "$dataHome/herdr/plugins/herdr-remote"
            ${pkgs.coreutils}/bin/cp -R ${herdrRemote} "$dataHome/herdr/plugins/herdr-remote"
            ${pkgs.coreutils}/bin/chmod -R u+w "$dataHome/herdr/plugins/herdr-remote"
            herdr plugin link "$dataHome/herdr/plugins/herdr-remote" --enabled >/dev/null
          '';
          ompShellHook = ''
            ${pkgs.coreutils}/bin/mkdir -p "$HOME/.omp/agent/extensions"
            ${pkgs.coreutils}/bin/install -m 600 ${ompConfig} "$HOME/.omp/agent/config.yml"
            herdr integration install omp >/dev/null
          '';
          agenticShellHook = ''
            ${herdrShellHook}
            ${ompShellHook}
          '';
          mkToolbox =
            name: packages: shellHook:
            pkgs.mkShell {
              inherit packages;
              shellHook = ''
                export SHELL="${pkgs.zsh}/bin/zsh"
                export TOOLBOX_NAME="${name}"
                ${shellHook}
              '';
            };
        in
        {
          devops = mkToolbox "devops" devopsPackages "";
          agentic = mkToolbox "agentic" agenticPackages agenticShellHook;
          agentic-devops = mkToolbox "agentic-devops" (agenticPackages ++ devopsPackages) agenticShellHook;
        }
      );

      checks = {
        x86_64-linux.forge = self.nixosConfigurations.forge.config.system.build.toplevel;
        aarch64-darwin.tinymac = self.darwinConfigurations.tinymac.config.system.build.toplevel;
      };
    };
}
