{ pkgs, pkgs-unstable, config, lib, ... }:
let
  cfg = config.host.services.jellyseerr;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 15;
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
      file = ../../secrets/nixie/Monitoring/Exporters/${config.host.name}/Jellyseer.age;
      owner = "root";
    };
  };

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config inputs lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "jellyseerr";
        containerPort = 5055;

        bindMounts = { "/var/lib/jellyseerr/" = { hostPath = "${cfg.dataDir}/jellyseerr"; isReadOnly = false; }; };

        cfg.services.jellyseerr = {
          enable = true;
#          package = pkgs-unstable.jellyseerr;
        };
      }
    )

    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        enable = cfg.enableExporter;
        dataDir = cfg.dataDir;
        fqdn = config.host.networking.monitoringDomain;

        name = "jellyseerr-exporter";
        image = "ghcr.io/opspotes/jellyseerr-exporter:1.4";
        containerID = 18;

        nginxLocation = "/jellyseerr-metrics";
        nginxProxyPassLocation = "/metrics";
        containerPort = 9850;

        environment = {
          JELLYSEERR_ADDRESS = "https://${cfg.subdomain}.${config.host.networking.domainName}";
          FULLDATA = "true";
        };

        environmentFiles = mkIf cfg.enableExporter [ config.age.secrets.Jellyseerr_Exporter-environment.path ];
      }
    )
  ];
}
