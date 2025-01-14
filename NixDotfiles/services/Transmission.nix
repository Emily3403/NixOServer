{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.transmission;
  utils = import ../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;
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
    ];

    age.secrets.Transmission = {
      file = ../secrets/${config.host.name}/Transmission.age;
      owner = "root";
    };

    age.secrets.Transmission_Exporter-environment = mkIf cfg.enableExporter {
      file = ../secrets/${config.host.name}/Monitoring/Exporters/Transmission.age;
      owner = "root";
    };
  };

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs;

        enable = true;
        name = "transmission";
        subdomain = cfg.subdomain;
        image = "haugene/transmission-openvpn:latest";
        dataDir = cfg.dataDir;

        containerID = 10;
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
        ];
      }
    )
  ];

  config = {
#    services.nginx.virtualHosts."${config.networking.hostName}.status.${config.host.networking.domainName}" = mkIf cfg.enableExporter utils.makeNginxMetricConfig "transmission" "10.88.2.10";

    virtualisation.oci-containers.containers.transmission-exporter = mkIf cfg.enableExporter {
      image = "evanofslack/transmission-exporter:latest";
      ports = [ "127.0.0.1::19091" ];
      extraOptions = [ "--ip=10.88.2.10" "--userns=keep-id" ];

      volumes = [
        "/etc/resolv.conf:/etc/resolv.conf:ro"
        "${config.age.secrets.Transmission_Exporter-environment.path}:${config.age.secrets.Transmission_Exporter-environment.path}"
      ];

      environment = {
        TZ = "Europe/Berlin";
        TRANSMISSION_ADDR = "https://${cfg.subdomain}.${config.host.networking.domainName}/transmission/rpc";
      };
      environmentFiles = [ config.age.secrets.Transmission_Exporter-environment.path ];
    };
  };


}
