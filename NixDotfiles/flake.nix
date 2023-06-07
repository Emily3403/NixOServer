{
  # TODO: flake-parts, systems, devenv
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.darwin.follows = "";
  };

  outputs = { self, nixpkgs, agenix }@inputs:
    let
      lib = nixpkgs.lib;
      mkHost = { zfs-root, pkgs, system, ... }:
        lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./modules
            agenix.nixosModules.default

            ./programs/KeyCloak.nix
            ./programs/Wiki-js.nix
            ./programs/Nginx.nix
            ./programs/Nextcloud.nix
          ];

          specialArgs = {
              inherit zfs-root inputs pkgs lib;
          };
        };
    in {
      nixosConfigurations = {
        exampleHost = let
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.${system};
        in mkHost (import ./hosts/exampleHost { inherit system pkgs; });
      };
    };
}
