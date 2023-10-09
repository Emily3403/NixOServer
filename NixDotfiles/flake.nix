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

            ./services/KeyCloak.nix
            ./services/Wiki-js.nix
            ./services/Nginx.nix
            ./services/Nextcloud.nix
            ./services/HedgeDoc.nix
            ./services/YouTrack.nix

            ./services/PasswordManagers/VaultWarden.nix

            ./services/Mail.nix

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
          pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };

          modules = [
            ./hosts/nixie-vm/networking.nix
          ];

        in mkHost (import ./hosts/nixie-vm { inherit system pkgs modules; });

        ruwusch = let
          system = "x86_64-linux";
          pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
          modules = [ ];
        in mkHost (import ./hosts/ruwusch { inherit system pkgs modules; });

      };
    };
}
