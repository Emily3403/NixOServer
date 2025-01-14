{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.transmission;
  _cfg = config;
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
      file = ../../secrets/${config.host.name}/Transmission.age;
      owner = "root";
    };

    age.secrets.Transmission_Exporter-environment = mkIf cfg.enableExporter {
      file = if config.host.name == "ruwusch" then ../../secrets/nixie/Monitoring/Exporters/Transmission.age else ../../secrets/nixie/Monitoring/Exporters/Old-Transmission.age;
      owner = "root";
    };
  };

  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;

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
          "${cfg.dataDir}/custom-configs:/etc/openvpn/custom/"
        ];
      }
    )
  ];

  config = {
    services.nginx.virtualHosts."${_cfg.networking.hostName}.status.${_cfg.host.networking.domainName}" = mkIf cfg.enableExporter {
      forceSSL = true;
      enableACME = true;
      locations."/transmission-metrics".proxyPass = "http://10.88.2.10:19091/metrics";
    };

    virtualisation.oci-containers.containers.transmission-exporter = mkIf cfg.enableExporter {
      image = "evanofslack/transmission-exporter:latest";
      ports = [ "127.0.0.1::19091" ];
      extraOptions = [ "--ip=10.88.2.10" "--userns=keep-id" ];

      volumes = [
        "/etc/resolv.conf:/etc/resolv.conf:ro"
        "${_cfg.age.secrets.Transmission_Exporter-environment.path}:${_cfg.age.secrets.Transmission_Exporter-environment.path}"
      ];

      environment = {
        TZ = "Europe/Berlin";
        TRANSMISSION_ADDR = "https://${cfg.subdomain}.${_cfg.host.networking.domainName}/transmission/rpc";
      };
      environmentFiles = [ _cfg.age.secrets.Transmission_Exporter-environment.path ];
    };

#    systemd.services.restart-transmission-exporter = mkIf cfg.enableExporter {
#      description = "Restart the Transmission exporter";
#      enable = true;
#      script = "systemctl restart podman-transmission-exporter";
#    };
#
#    systemd.timers.restart-transmission-exporter = mkIf cfg.enableExporter {
#      description = "Restart the Transmission exporter regularly";
#      enable = true;
#      wantedBy = [ "timers.target" ];
#      timerConfig = {
#        OnCalendar = "*-*-* 7:00:00";
#        Persistent = true;
#        RandomizedDelaySec = 10;
#      };
#    };
  };


}
