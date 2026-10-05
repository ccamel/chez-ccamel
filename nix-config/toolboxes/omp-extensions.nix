let
  extensions = builtins.fromJSON (builtins.readFile ./omp-npm-extensions.json);
in
map (extension: {
  package =
    { pkgs, ... }:
    (pkgs.callPackage ../packages/mk-omp-npm-extension.nix { }) (
      builtins.removeAttrs extension [ "documentation" ]
    );
  readmeGroup = "Extensions and integrations";
  documentation = {
    inherit (extension.documentation) name visibility;
    description = extension.documentation.description or extension.description;
    url = extension.homepage;
  };
}) extensions
