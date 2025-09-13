{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.transmission;
  _cfg = config;
  utils = import ../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 10;
in
{
  options.host.services.transmission = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Transmission";
    };

    subdomain = mkOption {
      type = types.str;
      default = "transui";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}/ 0750 jellyfin jellyfin"
      "d ${cfg.dataDir}/data/ 0750 jellyfin jellyfin"
      "d ${cfg.dataDir}/config/ 0750 jellyfin jellyfin"
      "d ${cfg.dataDir}/ui/ 0750 jellyfin jellyfin"
    ];

    age.secrets.Transmission = {
      file = ../../secrets/${config.host.name}/Transmission.age;
      owner = "root";
    };

    age.secrets.Other-Transmission = {
      file = ../../secrets/${config.host.name}/Other-Transmission.age;
      owner = "root";
    };

    age.secrets.Prometheus_Transmission-exporter = mkIf cfg.enableExporter {
      file = ../../secrets/nixie/Monitoring/Exporters/${config.host.name}/Transmission.age;
      owner = "root";
    };
  };

  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs containerID;
        subdomain = cfg.subdomain;
        dataDir = cfg.dataDir;

        name = "transmission";
        image = "haugene/transmission-openvpn:5.3";
        containerPort = 9091;

        additionalContainerConfig.extraOptions = [ "--cap-add=NET_ADMIN" "--device=/dev/net/tun" ];
        environment = {
          PUID = toString config.users.users.jellyfin.uid;
          PGID = toString config.users.groups.jellyfin.gid;
        };
        environmentFiles = [ config.age.secrets.Transmission.path ];

        volumes = [
          "${cfg.dataDir}/data:/data"
          "${cfg.dataDir}/config:/config"
          "${cfg.dataDir}/ui/:/opt/transmission-ui/" # TODO: Default config
          "${cfg.dataDir}/custom-configs:/etc/openvpn/custom/"
        ];
      }
    )

    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        enable = cfg.enableExporter;
        dataDir = cfg.dataDir;
        fqdn = config.host.networking.monitoringDomain;

        name = "transmission-exporter";
        image = "evanofslack/transmission-exporter:latest";
        containerID = 24;

        containerPort = 19091;
        nginxLocation = "/transmission-metrics";
        nginxProxyPassLocation = "/metrics";

        environment.TRANSMISSION_ADDR = "https://${cfg.subdomain}.${config.host.networking.domainName}/transmission/rpc";
        environmentFiles = [ config.age.secrets.Prometheus_Transmission-exporter.path ];
      }
    )
  ];

  config = {

    # This is needed because the transmission exporter doesn't support removing torrents. It will simply report the last value always.
    # Also, the data keeping in the exporter is sometimes messed up. Until I write a new exporter, this will be the fix.
    systemd.services.restart-transmission-exporter = mkIf cfg.enableExporter {
      description = "Restart the Transmission exporter";
      enable = true;
      script = "systemctl restart podman-transmission-exporter";
    };

    systemd.timers.restart-transmission-exporter = mkIf cfg.enableExporter {
      description = "Restart the Transmission exporter regularly";
      enable = true;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 7:00:00";
        Persistent = true;
        RandomizedDelaySec = 10;
      };
    };
  };

}
