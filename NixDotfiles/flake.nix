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
      mkHost = { zfs-root, pkgs, system, modules, ... }:
        lib.nixosSystem {
          inherit system;
          modules = lib.flatten [
            ./configuration.nix
            ./modules

            agenix.nixosModules.default
            ./secrets/secret-config.nix

            ./programs/Database.nix
            ./programs/KeyCloak.nix
            ./programs/Wiki-js.nix
            ./programs/Nginx.nix
            ./programs/Nextcloud.nix

            modules
          ];

          specialArgs = {
              inherit zfs-root inputs pkgs lib;
          };
        };

    in {
      nixosConfigurations = {
        nixie-vm = let
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.${system}.appendOverlays [ (import ./overlays/Wiki-js.nix) ];
          modules = [
            ./hosts/nixie-vm/networking.nix
          ];

        in mkHost (import ./hosts/nixie-vm { inherit system pkgs modules; });

        ruwusch = let
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.${system}.appendOverlays [ (import ./overlays/Wiki-js.nix) ];
          modules = [ ];
        in mkHost (import ./hosts/ruwusch { inherit system pkgs modules; });

      };
    };
}
