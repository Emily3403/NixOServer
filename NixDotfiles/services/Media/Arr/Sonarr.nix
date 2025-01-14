{ pkgs, pkgs-unstable, config, lib, ... }:
let
  cfg = config.host.services.sonarr;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 16;
in
{
  options.host.services.sonarr = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Sonarr";
    };

    subdomain = mkOption {
      type = types.str;
      default = "sonarr";
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 jellyfin"
      "d ${cfg.dataDir}/sonarr 0750 jellyfin"
    ];

  };

  imports = [
    (
      import ../../Container-Config/Nix-Container.nix {
        inherit config lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "sonarr";
        containerPort = 8989;
        isSystemUser = true;

        user = {
          name = "jellyfin";
          uid = 12009;
        };

        bindMounts = { "/var/lib/sonarr/" = { hostPath = "${cfg.dataDir}/sonarr"; isReadOnly = false; }; };

        cfg = {
          nixpkgs.config.permittedInsecurePackages = [
            "aspnetcore-runtime-6.0.36"
            "aspnetcore-runtime-wrapped-6.0.36"
            "dotnet-sdk-6.0.428"
            "dotnet-sdk-wrapped-6.0.428"
          ];

          services.sonarr = {
            enable = true;
            user = "jellyfin";
            group = "jellyfin";

            dataDir = "/var/lib/sonarr";
            package = pkgs-unstable.sonarr;
          };
        };
      }
    )
  ];
}
