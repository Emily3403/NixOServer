{ pkgs, config, lib, ... }:
let

  cfg = config.host.services.prometheus;
  inherit (lib) mkIf mkOption types foldl';

  mkBasicAuth = secretName: { username = "admin"; password_file = config.age.secrets.${secretName}.path; };

  # TODO: Refactor this
  mkScrapers = hostname: metrics:
    (foldl' (acc: metric: [{
      job_name = "${hostname}-${metric}";
      metrics_path = "/${metric}-metrics";
      scheme = "https";
      basic_auth = mkBasicAuth "Prometheus_${hostname}-pw";
      scrape_interval = if metric == "transmission" then "5s" else "30s";  # TODO: Make this configurable from the callee
      scrape_timeout = if metric == "transmission" then "5s" else "15s";
      static_configs = [{ targets = [ "${hostname}.status.${config.host.networking.domainName}" ]; }];
    }] ++ acc)) [ ]
      metrics;

   mkBearerScrapers = hostname: metrics:
    (foldl' (acc: metric: [{
      job_name = "${hostname}-${metric}";
      metrics_path = "/${metric}-metrics";
      scheme = "https";
      bearer_token_file = config.age.secrets."Prometheus_${metric}-API-key".path;
      scrape_interval = if metric == "transmission" then "5s" else "30s";
      static_configs = [{ targets = [ "${hostname}.status.${config.host.networking.domainName}" ]; }];
    }] ++ acc)) [ ]
      metrics;

in
{

  options.host.services.prometheus = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Prometheus";
    };

    subdomain = mkOption {
      type = types.str;
      default = "prometheus";
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 prometheus prometheus"
      "d ${cfg.dataDir}/prometheus2 0750 prometheus prometheus"
      "d ${cfg.dataDir}/prometheus2/config 0750 prometheus prometheus"
      "d ${cfg.dataDir}/prometheus2/data 0750 prometheus prometheus"
    ];

    age.secrets.Prometheus_syncthing-API-key = {
      file = ../../secrets/${config.host.name}/Monitoring/Access/Syncthing.age;
      owner = "prometheus";
    };

    age.secrets.Prometheus_ruwusch-pw = {
      file = ../../secrets/${config.host.name}/Monitoring/Access/ruwusch.age;
      owner = "prometheus";
    };
  };


  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;

        name = "prometheus";
        subdomain = cfg.subdomain;
        containerID = 12;
        containerPort = 9090;

        user.uid = 255;
        isSystemUser = true;

        bindMounts = {
          "/var/lib/prometheus2/" = { hostPath = "${cfg.dataDir}/prometheus2"; isReadOnly = false; };
          "${config.age.secrets.Prometheus_nixie-pw.path}".hostPath = config.age.secrets.Prometheus_nixie-pw.path;
          "${config.age.secrets.Prometheus_ruwusch-pw.path}".hostPath = config.age.secrets.Prometheus_ruwusch-pw.path;
          "${config.age.secrets.Prometheus_syncthing-API-key.path}".hostPath = config.age.secrets.Prometheus_syncthing-API-key.path;
        };

        cfg = {
          services.prometheus = {
            enable = true;
            retentionTime = "15y";
            checkConfig = "syntax-only";  # "If you use credentials stored in external files they will not be visible to promtool and it will report errors"
            webExternalUrl = "https://${cfg.subdomain}.${config.host.networking.domainName}";

            # Needed for htpasswd with basic_auth_users (https://prometheus.io/docs/prometheus/latest/configuration/https/)
            webConfigFile = "/var/lib/prometheus2/config/web-config.yaml";

            scrapeConfigs =
              let
                def = [ ];
              in
              # This can easily be extended to include more hosts
              (mkScrapers "ruwusch" ([ "prometheus" "transmission" "syncthing-exporter" "jellyfin" "nextcloud" "hedgedoc" ] ++ def)) ++
              (mkBearerScrapers "ruwusch" ([ "syncthing" ]))
            ;

          };
        };
      }
    )
  ];
}
