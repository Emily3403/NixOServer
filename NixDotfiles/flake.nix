{
  # TODO: flake-parts, systems, devenv

  description = "NixOS Server on ZFS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
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

              config.allowUnfree = true;
#              overlays = [ (import ...) ];
              config.packageOverrides = pkgs: {
                vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
              };

              config.permittedInsecurePackages = [
                "aspnetcore-runtime-6.0.36"
                "aspnetcore-runtime-wrapped-6.0.36"
                "dotnet-sdk-6.0.428"
                "dotnet-sdk-wrapped-6.0.428"
              ];
            };

            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;

              config.packageOverrides = pkgs: {
                ente-web = pkgs.ente-web.overrideAttrs {
                  env = { NEXT_PUBLIC_ENTE_ENDPOINT = "https://api.ente.ruwusch.de"; NEXT_PUBLIC_ENTE_ALBUMS_ENDPOINT = "https://albums.ruwusch.de"; };
                  # The number of max jobs is (currently) hardcoded in the source code. Change it to match a more demanding setting
                  postPatch = ''substituteInPlace apps/photos/src/services/upload/uploadManager.ts --replace-fail "const maxConcurrentUploads = 4;" "const maxConcurrentUploads = 12;"'';
                };
              };
            };

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

            # Configuration per host
            ./hosts/${hostName}
            ./users/hosts/${hostName}.nix
          ] ++ [{ system.stateVersion = stateVersion; }];
        };

    in
    {
      nixosConfigurations = {
        nixie = mkHost "nixie" "24.11" "x86_64-linux";
        ruwusch = mkHost "ruwusch" "23.11" "x86_64-linux";
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
