{
  # TODO: flake-parts, systems, devenv

  description = "NixOS Server on ZFS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
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
          pkgs = import nixpkgs { inherit system; config.packageOverrides = pkgs: { vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; }; }; };

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

    in
    {
      nixosConfigurations = {
        ruwuschOnNix = mkHost "ruwuschOnNix" "x86_64-linux";
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
