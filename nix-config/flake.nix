{
  description = "NixOS configuration for forge (on WSL2)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
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

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      devShells.x86_64-linux =
        let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          omp = pkgs.callPackage ./packages/omp.nix { };
          herdr = pkgs.callPackage ./packages/herdr.nix { };
          devopsPackages = import ./toolboxes/devops.nix { inherit pkgs; };
          agenticPackages = import ./toolboxes/agentic.nix { inherit pkgs omp herdr; };
        in
        {
          devops = pkgs.mkShell {
            packages = devopsPackages;
          };
          agentic = pkgs.mkShell {
            packages = agenticPackages;
          };
          agentic-devops = pkgs.mkShell {
            packages = agenticPackages ++ devopsPackages;
          };
        };

      checks.x86_64-linux.forge = self.nixosConfigurations.forge.config.system.build.toplevel;
    };
}
