{
  # TODO: flake-parts, systems, devenv

  description = "NixOS Server on ZFS";

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
            # By default, the system will only use packages from the stable channel.
            # You can selectively install packages from the unstable channel.
            # You can also add more  channels to pin package version.
            pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};

            # make all inputs availabe in other nix files
            inherit inputs;
          };

          modules = [
            # Root on ZFS related configuration
            ./modules

            # Configuration shared by all hosts
            ./configuration.nix
            ./system.nix
            ./users/root.nix
            ./secrets/secret-config.nix
            agenix.nixosModules.default

            # Configuration per host
            ./hosts/${hostName}
          ];
        };

    in {
      nixosConfigurations = {
        ruwuschOnNix = mkHost "ruwuschOnNix" "x86_64-linux";
      };
    };
}
