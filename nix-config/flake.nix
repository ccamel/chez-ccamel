{
  description = "NixOS configuration for forge (on WSL2)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

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

      formatter = forEachSystem (
        system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style
      );

      devShells = forEachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          omp = pkgs.callPackage ./packages/omp.nix { };
          herdr = pkgs.callPackage ./packages/herdr.nix { };
          devopsPackages = import ./toolboxes/devops.nix { inherit pkgs; };
          agenticPackages = import ./toolboxes/agentic.nix { inherit pkgs omp herdr; };
          mkToolbox =
            packages:
            pkgs.mkShell {
              inherit packages;
              shellHook = ''
                export SHELL="${pkgs.zsh}/bin/zsh"
              '';
            };
        in
        {
          devops = mkToolbox devopsPackages;
          agentic = mkToolbox agenticPackages;
          agentic-devops = mkToolbox (agenticPackages ++ devopsPackages);
        }
      );

      checks = {
        x86_64-linux.forge = self.nixosConfigurations.forge.config.system.build.toplevel;
        aarch64-darwin.tinymac = self.darwinConfigurations.tinymac.config.system.build.toplevel;
      };
    };
}
