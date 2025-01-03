{ config, lib, pkgs, ... }:
let
  cfg = config;
  inherit (lib) mkIf types mkOption foldl';

  mkOpt = name: default:
    mkOption {
      description = "Enable ${name} exporter";
      type = types.bool;
      default = default;
    };

in
{

  options.monitoredServices = mkOption {
    description = "Services to monitor";
    default = {};
    type = types.submodule {
      options = {
        # TODO: Make this dependent on enable options
        # Default options
        hedgedoc = mkOpt "HedgeDoc" cfg.services.hedgedoc.enable;
        nextcloud = mkOpt "Nextcloud" cfg.services.nextcloud.enable;
        nginx = mkOpt "Nginx" cfg.services.nginx.enable;
        nginxlog = mkOpt "Nginxlog" cfg.services.nginx.enable;
        prometheus = mkOpt "Prometheus" cfg.services.prometheus.enable;
        restic = mkOpt "Restic" (cfg.services.restic.backups != {});
        zfs = mkOpt "ZFS" cfg.boot.zfs.enabled;
        netbox = mkOpt "Netbox" false;
        mattermost = mkOpt "Mattermost" cfg.services.mattermost.enable;
        transmission = mkOpt "Transmission";
        syncthing = mkOpt "Syncthing";

        # TODO
#        wireguard = mkOpt "Wireguard";
#        postgres = mkOpt "Postgres";
#        bind = mkOpt "Bind DNS Server";
#        idrac = mkOpt "iDRAC";
#        ipmi = mkOpt "IPMI";
        smartctl = mkOpt "Smartctl" true;  # TODO: devices
#        mail = TODO;
#        keycloak = TODO;
#        onlyoffice = TODO;
      };
    };

  };


  config = {

#    # Enable all exporters that do not require additional configuration
#    services.prometheus.exporters = foldl'
#      (acc: it: {
#        "${it}" = mkIf cfg.monitoredServices.${it} {
#          enable = true;
#          telemetryPath = "/${it}-metrics";
#        };
#      } // acc)
#      { } [ "nginx" "zfs" ] // {
#
#      # Now add the exporters that require additional configuration
#      # bind = {};
#      # openldap = {};
#      # idrac = {};
#      # impi = {};
#      # nextcloud = {};
#      # postgres = {};
#
#
#      nginxlog = mkIf cfg.monitoredServices.nginxlog {
#        enable = true;
#        group = "nginx";  # Needed for access to the log file
#        metricsEndpoint = "/nginxlog-metrics";
#
#        settings.namespaces = [{
#          name = "nginxlog";
#          format = "$remote_addr - $remote_user [$time_local] \"$request\" $status $body_bytes_sent \"$http_referer\" \"$http_user_agent\" rt=$request_time uct=\"$upstream_connect_time\" uht=\"$upstream_header_time\" urt=\"$upstream_response_time\"";
#          source.files = [ "/var/log/nginx/access.log" ];
#        }];
#      };
#
#      smartctl = mkIf cfg.monitoredServices.smartctl {
#        enable = true;
#        devices = cfg.host.bootDevices;
#        extraFlags = [ "--web.telemetry-path=/smartctl-metrics" ];
#      };
#
#    };
#
#    # Enable monitoring options of services
#    services.nginx.statusPage = cfg.monitoredServices.nginx;
#    systemd.services."prometheus-nginx-exporter" = mkIf cfg.monitoredServices.nginx {
#      after = [ "nginx.service" ];
#    };

# TODO
#     virtualisation.oci-containers.containers.syncthing-exporter = mkIf cfg.enableExporter {
#        image = "f100024/syncthing_exporter:latest";
#        ports = [ "127.0.0.1::9093" ];
#        extraOptions = [ "--ip=10.88.99.1" "--userns=keep-id" ];
#        volumes = [ "/etc/resolv.conf:/etc/resolv.conf:ro" ];
#
#        environment = {
#          TZ = "Europe/Berlin";
#          SYNCTHING_URI = "https://sync.${config.host.networking.domainName}";
#          SYNCTHING_FOLDERSID = "azh4c-aq7pu,ffue9-gmezi,sgict-7ax3q,k1clh-49g30,fawqz-qrwh9,xzn9v-cdks5,ccnor-nqwwx,rxr7g-6d9sj,pixel_8_pro_cbv4-photos,nemob-qvlak,ejzzq-xsisq,8f158-ftdx5,oihrs-rmamj,dhwha-w9hst,xdwjc-lrumz";
#        };
#        environmentFiles = [ config.age.secrets.Prometheus_syncthing-exporter-environment.path ];
#      };
#
#    # Enable Docker monitoring
#    virtualisation.oci-containers = let
#      mkResticExporter = name: ip: {
#        image = "ngosang/restic-exporter";
#        ports = [ "127.0.0.1::8001" ];
#        extraOptions = [ "--ip=${ip}" "--userns=keep-id" ];
#
#        volumes = [
#          "/etc/resolv.conf:/etc/resolv.conf:ro"
#          "${config.age.secrets."Restic_${name}-pw".path}:${config.age.secrets."Restic_${name}-pw".path}"
#          "${config.age.secrets."Restic_${name}-env".path}:${config.age.secrets."Restic_${name}-env".path}"
#        ];
#
#        environment = {
#          TZ = "Europe/Berlin";
#          RESTIC_REPOSITORY = "rest:https://${name}-restic.${config.host.networking.domainName}/${config.host.name}";
#          RESTIC_PASSWORD_FILE = config.age.secrets."Restic_${name}-pw".path;
#          REFRESH_INTERVAL="900";  # 15min
#          NO_CHECK="True";
#        };
#        environmentFiles = [ config.age.secrets."Restic_${name}-env".path ];
#      };
#
#    in {
#      containers.en-restic-exporter = mkIf cfg.monitoredServices.restic (mkResticExporter "en" "10.88.5.2");
#      containers.mar-restic-exporter = mkIf cfg.monitoredServices.restic (mkResticExporter "mar" "10.88.5.3");
#    };
#
#    # Finally, setup the correct nginx paths
#    services.nginx.virtualHosts = mkIf (config.monitoredServices != { }) {
#      "${config.host.name}.observer.${config.host.networking.domainName}" = {
#        forceSSL = true;
#        enableACME = true;
#        basicAuthFile = config.age.secrets.Monitoring_host-htpasswd.path;
#
#        locations = foldl'
#          # First the exporters that are simply passed through
#          (acc: it: {
#            "/${it}-metrics".proxyPass = mkIf cfg.monitoredServices."${it}" "http://127.0.0.1:${toString cfg.services.prometheus.exporters.${it}.port}";
#          } // acc)
#          { "/".return = "403"; } [ "zfs" "nginx" "nginxlog" ] // {
#
#          # Now the exporters that require additional configuration
#          "/prometheus-metrics".proxyPass = mkIf cfg.monitoredServices.prometheus "http://192.168.7.112:9090/metrics";
#          "/en-restic-metrics".proxyPass = mkIf cfg.monitoredServices.restic "http://10.88.5.2:8001/metrics";
#          "/mar-restic-metrics".proxyPass = mkIf cfg.monitoredServices.restic "http://10.88.5.3:8001/metrics";
#          "/hedgedoc-metrics".proxyPass = mkIf cfg.monitoredServices.hedgedoc "http://192.168.7.104:3000/metrics";
#          "/nextcloud-metrics".proxyPass = mkIf cfg.monitoredServices.nextcloud "http://192.168.7.103:9205/metrics";
#          "/netbox-metrics".proxyPass = mkIf cfg.monitoredServices.netbox "http://10.88.5.1:8000/metrics";
#          "/mattermost-metrics".proxyPass = mkIf cfg.monitoredServices.mattermost "http://192.168.7.116:8067/metrics";
#        };
#      };
#
#    # TODO: Move the individual expers to their files
#    virtualisation.oci-containers.containers.transmission-exporter = mkIf cfg.monitoredServices.transmission {
#      image = "evanofslack/transmission-exporter:latest";
#      ports = [ "127.0.0.1::19091" ];
#      extraOptions = [ "--ip=10.88.2.2" "--userns=keep-id" ];
#
#      volumes = [
#        "/etc/resolv.conf:/etc/resolv.conf:ro"
#        "${config.age.secrets.Transmission_Exporter-environment.path}:${config.age.secrets.Transmission_Exporter-environment.path}"
#      ];
#
#      environment = {
#        TZ = "Europe/Berlin";
#        TRANSMISSION_ADDR = "https://transmission.${config.host.networking.domainName}/transmission/rpc";
#      };
#      environmentFiles = [ config.age.secrets.Transmission_Exporter-environment.path ];
#    };
#
#    systemd.services.restart-transmission-exporter = {
#      description = "Restart the Transmission exporter";
#      enable = true;
#      script = "systemctl restart podman-transmission-exporter";
#    };
#
#    systemd.timers.restart-transmission-exporter = {
#      description = "Restart the Transmission exporter regularly";
#      enable = true;
#      wantedBy = [ "timers.target" ];
#      timerConfig = {
#        OnCalendar = "*-*-* 7:00:00";
#        Persistent = true;
#        RandomizedDelaySec = 10;
#      };
#    };
#
#
#    services.nginx.virtualHosts = mkIf (config.monitoredServices != [ ]) {
#      "${config.networking.hostName}.status.${config.host.networking.domainName}" = {
#        forceSSL = true;
#        enableACME = true;
#        basicAuthFile = config.age.secrets.Monitoring_host-htpasswd.path;
#
#        # TODO: Make this only if cfg.{it} is enabled
#        locations = {
#          "/".return = "403";
#          "/prometheus-metrics".proxyPass = "http://192.168.7.112:9090/metrics";
#          "/jellyfin-metrics".proxyPass = "http://192.168.7.109:8096/metrics";
#          "/nextcloud-metrics".proxyPass = "http://192.168.7.103:9205/metrics";
#          "/hedgedoc-metrics".proxyPass = "http://192.168.7.104:3000/metrics";
#
#          "/photoprism-metrics" = {
#            proxyPass = "http://192.168.7.110:2342/api/v1/metrics";
#            extraConfig = "auth_basic off;";  # Authentication is handled by a Bearer API Token, not plainauth
#          };
#          "/syncthing-metrics" = {
#            proxyPass = "http://192.168.7.105:8080/metrics";
#            extraConfig = "auth_basic off;";  # Authentication is handled by a Bearer API Token, not plainauth
#          };
#
#          "/transmission-metrics".proxyPass = "http://10.88.2.2:19091/metrics";
#          "/syncthing-exporter-metrics".proxyPass = "http://10.88.99.1:9093/metrics";
#        };
#      };
#    };
#  };
   };

}
