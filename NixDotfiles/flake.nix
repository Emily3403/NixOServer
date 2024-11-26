{
  # TODO: flake-parts, systems, devenv

  description = "NixOS Server on ZFS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.darwin.follows = "";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, agenix }@inputs:
    let
      mkHost = hostName: stateVersion: system:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            # By default, the system will only use packages from the stable channel.
            # You can selectively install packages from the unstable channel.
            # You can also add more  channels to pin package version.
            pkgs = import nixpkgs {
              inherit system;
              config.packageOverrides = pkgs: { vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; }; };
            };

            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.packageOverrides = pkgs: { ente-web = pkgs.ente-web.overrideAttrs {
                env = { NEXT_PUBLIC_ENTE_ENDPOINT="https://api.ente.ruwusch.de"; };

                # The number of max jobs is (currently) hardcoded in the source code. Change it to match a more demanding setting
                postPatch = ''substituteInPlace apps/photos/src/services/upload/uploadManager.ts --replace-fail "const maxConcurrentUploads = 4;" "const maxConcurrentUploads = 24;"'';
              }; };
            };
            pkgs-unfree = import nixpkgs { inherit system; config = { allowUnfree = true; }; };

            # make all inputs availabe in other nix files
            inherit inputs;
          };

          modules = [
            # Root on ZFS related configuration
            ./modules

            # Configuration shared by all hosts
            ./configuration.nix
            ./system.nix
            agenix.nixosModules.default

            # Users
            ./users/default.nix

            # Configuration per host
            ./hosts/${hostName}
          ] ++ [ { system.stateVersion = stateVersion; } ];
        };

    in
    {
      nixosConfigurations = {
        ruwusch = mkHost "ruwusch" "23.11" "x86_64-linux";
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
