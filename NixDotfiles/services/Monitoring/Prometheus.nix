{ pkgs, config, lib, ... }:
let

  inherit (lib) foldl';
  DATA_DIR = "/data/Prometheus";
  mkBasicAuth = secretName: { username = "admin"; password_file = config.age.secrets.${secretName}.path; };

  # TODO: Refactor this
  mkScrapers = hostname: metrics:
    (foldl' (acc: metric: [{
      job_name = "${hostname}-${metric}";
      metrics_path = "/${metric}-metrics";
      scheme = "https";
      basic_auth = mkBasicAuth "Prometheus_${hostname}-pw";
      scrape_interval = if metric == "transmission" then "10s" else "30s";  # TODO: Make this configurable from the callee
      scrape_timeout = if metric == "transmission" then "10s" else "15s";
      static_configs = [{ targets = [ "${hostname}.status.${config.domainName}" ]; }];
    }] ++ acc)) [ ]
      metrics;

   mkBearerScrapers = hostname: metrics:
    (foldl' (acc: metric: [{
      job_name = "${hostname}-${metric}";
      metrics_path = "/${metric}-metrics";
      scheme = "https";
      bearer_token_file = config.age.secrets."Prometheus_${metric}-API-key".path;
      scrape_interval = if metric == "transmission" then "5s" else "30s";
      static_configs = [{ targets = [ "${hostname}.status.${config.domainName}" ]; }];
    }] ++ acc)) [ ]
      metrics;

in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 prometheus prometheus"
    "d ${DATA_DIR}/prometheus2 0750 prometheus prometheus"
    "d ${DATA_DIR}/prometheus2/config 0750 prometheus prometheus"
    "d ${DATA_DIR}/prometheus2/data 0750 prometheus prometheus"
  ];

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "prometheus";
        containerIP = "192.168.7.112";
        containerPort = 9090;
        subdomain = "prometheus";

        imports = [ ../../users/services/Monitoring/prometheus.nix ];
        bindMounts = {
          "/var/lib/prometheus2/" = { hostPath = "${DATA_DIR}/prometheus2"; isReadOnly = false; };
          "${config.age.secrets.Prometheus_ruwusch-pw.path}".hostPath = config.age.secrets.Prometheus_ruwusch-pw.path;
          "${config.age.secrets.Prometheus_syncthing-API-key.path}".hostPath = config.age.secrets.Prometheus_syncthing-API-key.path;
          "${config.age.secrets.Prometheus_photoprism-API-key.path}".hostPath = config.age.secrets.Prometheus_photoprism-API-key.path;
        };

        # Increase the wait timeout for grafana, because ruwusch is really slow
        additionalNginxConfig.extraConfig = ''
          proxy_read_timeout 3600;
          proxy_connect_timeout 3600;
          proxy_send_timeout 3600;
        '';

        cfg = {
          services.prometheus = {
            enable = true;
            retentionTime = "1y";
            checkConfig = "syntax-only";  # "If you use credentials stored in external files they will not be visible to promtool and it will report errors"
            webExternalUrl = "https://prometheus.${config.domainName}";

            # Needed for htpasswd with basic_auth_users (https://prometheus.io/docs/prometheus/latest/configuration/https/)
            webConfigFile = "/var/lib/prometheus2/config/web-config.yaml";

            scrapeConfigs =
              let
                def = [ ];
              in
              # This can easily be extended to include more hosts
              (mkScrapers "ruwusch" ([ "prometheus" "transmission" "syncthing-exporter" "jellyfin" "nextcloud" "hedgedoc" ] ++ def)) ++
              (mkBearerScrapers "ruwusch" ([ "syncthing" "photoprism" ]))
            ;

          };
        };
      }
    )
  ];
}
