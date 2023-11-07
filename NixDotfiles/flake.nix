{
  # TODO: flake-parts, systems, devenv

  description = "Barebones NixOS on ZFS config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/master";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.darwin.follows = "";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, agenix }@inputs:
    let
      mkHost = hostName: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          pkgs = nixpkgs.legacyPackages.${system};

          specialArgs = {
            # By default, the system will only use packages from the
            # stable channel.  You can selectively install packages
            # from the unstable channel.  You can also add more
            # channels to pin package version.
            pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};

            # make all inputs availabe in other nix files
            inherit inputs;
          };

          modules = [
            # Root on ZFS related configuration
            ./modules

            # Configuration shared by all hosts
            ./configuration.nix
            ./secrets/secret-config.nix
            agenix.nixosModules.default

            # Configuration per host
            ./hosts/${hostName}
            ./hosts/${hostName}/networking.nix

            # TODO: Refactor this to be host-specific
            ./services/Nginx.nix
            ./services/HedgeDoc.nix
            ./services/KeyCloak.nix
            ./services/Nextcloud.nix
            ./services/Wiki-js.nix
            ./services/YouTrack.nix

          ];
        };

    in {

      nixosConfigurations = {
        ruwuschOnNix = mkHost "ruwuschOnNix" "x86_64-linux";
      };

    };
}
