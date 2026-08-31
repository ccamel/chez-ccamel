[
  {
    package = { pkgs, ... }: pkgs.callPackage ../packages/omp-undo-redo.nix { };
    readmeGroup = "Extensions and integrations";
    documentation = {
      name = "OMP Undo/Redo";
      description = "Session-navigation history controls for OMP.";
      url = "https://github.com/Baylar55/omp-undo-redo";
      visibility = "public";
    };
  }
  {
    package = { pkgs, ... }: pkgs.callPackage ../packages/ponytail.nix { };
    readmeGroup = "Extensions and integrations";
    documentation = {
      name = "Ponytail";
      description = "Opinionated minimalism modes and skills for OMP.";
      url = "https://github.com/DietrichGebert/ponytail";
      visibility = "public";
    };
  }
]
