{ pkgs, config, lib, ... }:
let

  cfg = config.host.services.prometheus;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types foldl';

  containerID = 12;

  mkBasicAuth = secretName: { username = "admin"; password_file = config.age.secrets.${secretName}.path; };

  # TODO: Refactor this
  mkScrapers = hostname: metrics:
    (foldl' (acc: metric: [{
      job_name = "${hostname}-${metric}";
      metrics_path = "/${metric}-metrics";
      scheme = "https";
      basic_auth = mkBasicAuth "Prometheus_${hostname}";
      scrape_interval = if metric == "transmission" || metric == "wireguard" then "5s" else "30s"; # TODO: Make this configurable from the callee
      scrape_timeout =  if metric == "transmission" || metric == "wireguard" then "5s" else "15s";
      static_configs = [{ targets = [ "${hostname}.status.${config.host.networking.domainName}" ]; }];
    }] ++ acc)) [ ]
      metrics;

  mkBearerScrapers = hostname: metrics:
    (foldl' (acc: metric: [{
      job_name = "${hostname}-${metric}";
      metrics_path = "/${metric}-metrics";
      scheme = "https";
      bearer_token_file = config.age.secrets."Prometheus_${metric}-API-key".path;
      scrape_interval = "30s";
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
      file = ../../secrets/${config.host.name}/Monitoring/Access/nixie/Syncthing.age;
      owner = "prometheus";
    };

    age.secrets.Prometheus_ruwusch = {
      file = ../../secrets/${config.host.name}/Monitoring/Access/ruwusch.age;
      owner = "prometheus";
    };

    services.nginx.virtualHosts."${config.host.networking.monitoringDomain}" = utils.makeNginxMetricConfig "prometheus" (utils.makeNixContainerIP containerID) "9090";
  };


  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "prometheus";
        containerPort = 9090;

        user.uid = 255;
        isSystemUser = true;

        additionalNginxConfig.locations."/metrics".return = "403";

        bindMounts = {
          "/var/lib/prometheus2/" = { hostPath = "${cfg.dataDir}/prometheus2"; isReadOnly = false; };
          "${config.age.secrets.Prometheus_nixie.path}".hostPath = config.age.secrets.Prometheus_nixie.path;
          "${config.age.secrets.Prometheus_ruwusch.path}".hostPath = config.age.secrets.Prometheus_ruwusch.path;
          "${config.age.secrets.Prometheus_syncthing-API-key.path}".hostPath = config.age.secrets.Prometheus_syncthing-API-key.path;
        };

        cfg = {
          services.prometheus = {
            enable = true;
            retentionTime = "15y";
            checkConfig = "syntax-only"; # "If you use credentials stored in external files they will not be visible to promtool and it will report errors"
            webExternalUrl = "https://${cfg.subdomain}.${config.host.networking.domainName}";

            # Needed for htpasswd with basic_auth_users (https://prometheus.io/docs/prometheus/latest/configuration/https/)
            webConfigFile = "/var/lib/prometheus2/config/web-config.yaml";

            scrapeConfigs =
              let
                def = [ "keycloak" "nextcloud" "hedgedoc" ];
              in
              # This can easily be extended to include more hosts
              (mkScrapers "nixie" ([ "prometheus" "syncthing-exporter" ] ++ def)) ++
              (mkScrapers "ruwusch" ([ "transmission" "jellyfin" "wireguard" ] ++ def)) ++

              (mkBearerScrapers "nixie" ([ "syncthing" ]))
            ;

          };
        };
      }
    )
  ];
}
