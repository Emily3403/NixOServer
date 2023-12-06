{
  # TODO: flake-parts, systems, devenv

  description = "NixOS Server on ZFS";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.darwin.follows = "";
    };
  };

  outputs = { self, nixpkgs, agenix }@inputs:
    let
      mkHost = hostName: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          pkgs = nixpkgs.legacyPackages.${system};

          specialArgs = {
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

    in
    {
      nixosConfigurations = {
        ruwuschOnNix = mkHost "ruwuschOnNix" "x86_64-linux";
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
