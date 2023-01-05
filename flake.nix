{
  description = "TS Server nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    dream2nix.url = "github:nix-community/dream2nix";
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, dream2nix, gitignore, ... }@inp:
    let
      npmPackage = dream2nix.lib.makeFlakeOutputs {
        systems = flake-utils.lib.defaultSystems;
        config.projectRoot = ./.;
        source = gitignore.lib.gitignoreSource ./.;
        projects = {
          typescript-language-server = {
            name = "typescript-language-server";
            subsystem = "nodejs";
            translator = "yarn-lock";
          };
        };
      };

      deps = flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          formatter = pkgs.nixpkgs-fmt;
        });
    in

    nixpkgs.lib.recursiveUpdate npmPackage deps;
}
