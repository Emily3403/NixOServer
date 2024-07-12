{ config, lib, pkgs, ... }:
let
  cfg = config;
  inherit (lib) mkIf types mkOption foldl';

  mkOpt = name:
    mkOption {
      description = "Enable ${name} exporter";
      type = types.bool;
      default = false;
    };

in
{

  options.monitoredServices = mkOption {
    description = "Services to monitor";
    type = types.submodule {
      options = {
        prometheus = mkOpt "Prometheus";
        transmission = mkOpt "Transmission";
        syncthing = mkOpt "Syncthing";
      };
    };

  };


  config = {

    # TODO: Move the individual expers to their files
    virtualisation.oci-containers.containers.transmission-exporter = mkIf cfg.monitoredServices.transmission {
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

    virtualisation.oci-containers.containers.syncthing-exporter = mkIf cfg.monitoredServices.syncthing {
      image = "f100024/syncthing_exporter:latest";
      ports = [ "127.0.0.1::9093" ];
      extraOptions = [ "--ip=10.88.99.1" "--userns=keep-id" ];
      volumes = [ "/etc/resolv.conf:/etc/resolv.conf:ro" ];

      environment = {
        TZ = "Europe/Berlin";
        SYNCTHING_URI = "https://sync.${config.domainName}";
        SYNCTHING_FOLDERSID = "azh4c-aq7pu,ffue9-gmezi,sgict-7ax3q,k1clh-49g30,fawqz-qrwh9,ccnor-nqwwx,rxr7g-6d9sj,pixel_8_pro_cbv4-photos,19a8v-x1nqh,nemob-qvlak,ejzzq-xsisq,8f158-ftdx5,oihrs-rmamj,dhwha-w9hst,xdwjc-lrumz";
      };
      environmentFiles = [ config.age.secrets.Syncthing_Exporter-environment.path ];
    };



    services.nginx.virtualHosts = mkIf (config.monitoredServices != [ ]) {
      "${config.networking.hostName}.status.${config.domainName}" = {
        forceSSL = true;
        enableACME = true;
        basicAuthFile = config.age.secrets.Monitoring_host-htpasswd.path;

        # TODO: Make this only if cfg.{it} is enabled
        locations = {
          "/".return = "403";
          "/prometheus-metrics".proxyPass = "http://192.168.7.112:9090/metrics";
          "/transmission-metrics".proxyPass = "http://10.88.2.2:19091/metrics";
          "/jellyfin-metrics".proxyPass = "http://192.168.7.109:8096/metrics";
          "/syncthing-metrics" = {
            proxyPass = "http://192.168.7.105:8080/metrics";
            extraConfig = "auth_basic off;";  # Authentication is handled by a Bearer API Token, not plainauth
          };
          "/syncthing-exporter-metrics".proxyPass = "http://10.88.99.1:9093/metrics";
        };
      };
    };
  };

}
