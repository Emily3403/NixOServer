{ pkgs, pkgs-unstable, config, lib, ... }:
let
  cfg = config.host.services.jellyseerr;
  inherit (lib) mkIf mkOption types;
in
{
  options.host.services.jellyseerr = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Jellyseerr";
    };

    subdomain = mkOption {
      type = types.str;
      default = "wishlist";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 jellyseerr"
      "d ${cfg.dataDir}/jellyseerr 0750 jellyseerr"
    ];

    age.secrets.Jellyseerr_Exporter-environment = mkIf cfg.enableExporter {
      file = ../../secrets/nixie/Monitoring/Exporters/Jellyseer.age;
      owner = "root";
    };
  };

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;

        name = "jellyseerr";
        subdomain = cfg.subdomain;
        containerID = 15;
        containerPort = 5055;

        bindMounts = {
          "/var/lib/jellyseerr/" = { hostPath = "${cfg.dataDir}/jellyseerr"; isReadOnly = false; };
        };

        cfg.services.jellyseerr = {
          enable = true;
#          package = pkgs-unstable.jellyseerr;
        };
      }
    )

    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;

        enable = true;
        name = "jellyseerr-exporter";
        image = "ghcr.io/opspotes/jellyseerr-exporter:latest";
        dataDir = cfg.dataDir;

        subdomain = "${config.host.name}.status";
        nginxLocation = "/jellyseerr-metrics";
        containerID = 18;
        containerPort = 9850;

        environmentFiles = mkIf cfg.enableExporter [ config.age.secrets.Jellyseerr_Exporter-environment.path ];
        additionalContainerConfig.entrypoint = "sleep";
        additionalContainerConfig.cmd = [
          "120"
          "--jellyseerr.address=https://${cfg.subdomain}.${config.host.networking.domainName}"
          "--jellyseerr.apiKey=$JELLYSEERR_API_KEY"
        ];

      }
    )
  ];
}
