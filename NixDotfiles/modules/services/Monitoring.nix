{ config, lib, pkgs, ... }:
let
  cfg = config;
  inherit (lib) mkIf types mkOption foldl';

in
{

  options.monitoredServices = mkOption {
    description = "Services to monitor";
    type = types.submodule {
      options = {
        prometheus = mkOption {
          description = "Prometheus";
          default = null;
          type = types.nullOr (types.submodule {
            options = {
              enable = mkOption {
                description = "Enable prometheus exporter";
                type = types.bool;
                default = false;
              };
            };
          });
        };

        transmission = mkOption {
          description = "Prometheus";
          default = null;
          type = types.nullOr (types.submodule {
            options = {
              enable = mkOption {
                description = "Enable Transmission exporter";
                type = types.bool;
                default = false;
              };
            };
          });
        };
      };
    };

  };


  config = {

    virtualisation.oci-containers.containers.transmission-exporter = mkIf (cfg.monitoredServices.transmission != null) {
      image = "evanofslack/transmission-exporter:latest";
      ports = [ "127.0.0.1::19091" ];
      extraOptions = [ "--ip=10.88.2.2" "--userns=keep-id" ];

      volumes = [
        "/etc/resolv.conf:/etc/resolv.conf:ro"
        "${config.age.secrets.Transmission_Exporter-environment.path}:${config.age.secrets.Transmission_Exporter-environment.path}"
      ];

      environment = {
        TZ = "Europe/Berlin";
        TRANSMISSION_ADDR = "https://transmission.${config.domainName}/transmission/rpc";
      };
      environmentFiles = [ config.age.secrets.Transmission_Exporter-environment.path ];
    };

    services.nginx.virtualHosts = mkIf (config.monitoredServices != [ ]) {
      "${config.networking.hostName}.status.${config.domainName}" = {
        forceSSL = true;
        enableACME = true;
        basicAuthFile = config.age.secrets.Monitoring_host-htpasswd.path;

        locations = {
          "/".return = "403";
          "/prometheus-metrics".proxyPass = "http://192.168.7.112:9090/metrics";
          "/transmission-metrics".proxyPass = "http://10.88.2.2:19091/metrics";
        };
      };
    };
  };

}
