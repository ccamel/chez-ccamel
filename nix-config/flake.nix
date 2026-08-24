{
  description = "NixOS and nix-darwin configurations for multiple hosts and environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-codex.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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
    { self, nixpkgs, ... }@inputs:
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

          omp = pkgs.callPackage ./packages/omp.nix { };
          herdr = pkgs.callPackage ./packages/herdr.nix { };
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
              shepherdr
              herd
              rtk
              livediff
              ;
            inherit (codexPkgs) codex;
            antigravityCli = codexPkgs.antigravity-cli;
            githubCopilotCli = codexPkgs.github-copilot-cli;
          };
          devopsPackages = map (descriptor: descriptor.package toolboxArgs) devopsToolbox;
          agenticPackages = map (descriptor: descriptor.package toolboxArgs) agenticToolbox;
          herdrOmpIntegrationHook = ''
            mkdir -p "$HOME/.omp/agent/extensions"
            herdr integration install omp
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
          agentic = mkToolbox "agentic" agenticPackages herdrOmpIntegrationHook;
          agentic-devops = mkToolbox "agentic-devops" (
            agenticPackages ++ devopsPackages
          ) herdrOmpIntegrationHook;
        }
      );

      checks = {
        x86_64-linux.forge = self.nixosConfigurations.forge.config.system.build.toplevel;
        aarch64-darwin.tinymac = self.darwinConfigurations.tinymac.config.system.build.toplevel;
      };
    };
}
