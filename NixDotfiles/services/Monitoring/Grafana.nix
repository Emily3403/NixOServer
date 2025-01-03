{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Grafana"; in
{
  systemd.tmpfiles.rules = [
    "d ${cfg.dataDir} 0750 grafana"
    "d ${cfg.dataDir}/grafana 0750 grafana"
    "d ${cfg.dataDir}/postgresql 0750 postgres"
  ];

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "grafana";
        subdomain = "status";
        containerIP = "192.168.7.113";
        containerPort = 3000;
        postgresqlName = "grafana";

        imports = [ ../../users/services/Monitoring/grafana.nix ];
        bindMounts = {
          "/var/lib/grafana/" = { hostPath = "${cfg.dataDir}/grafana"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${cfg.dataDir}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.Grafana_admin-pw.path}".hostPath = config.age.secrets.Grafana_admin-pw.path;
          "${config.age.secrets.Grafana_secret-key.path}".hostPath = config.age.secrets.Grafana_secret-key.path;
          "${config.age.secrets.Prometheus_ruwusch-pw.path}".hostPath = config.age.secrets.Prometheus_ruwusch-pw.path;
        };

        cfg = {
          services.grafana = {
            enable = true;
            declarativePlugins = null;

            settings = {
              server = {
                root_url = "https://status.${config.host.networking.domainName}";
                domain = "status.${config.host.networking.domainName}";
                enforce_domain = true;
                enable_gzip = true;
                http_addr = "0.0.0.0";
              };

              database = {
                type = "postgres";
                host = "/run/postgresql";
                name = "grafana";
                user = "grafana";
              };

              security = {
                admin_user = "admin";
                admin_password = "$__file{${config.age.secrets.Grafana_admin-pw.path}}";
#                admin_email = "admins@inet.tu-berlin.de";

                secret_key = "$__file{${config.age.secrets.Grafana_secret-key.path}}";
                cookie_secure = true;
                cookie_samesite = "lax"; # TODO: "strict"?
                strict_transport_security = false; # TODO
              };

              users = {
                allow_sign_up = false;
                default_theme = "dark";
              };

              analytics = {
                reporting_enabled = false;
                check_for_updates = true;
                check_for_plugin_updates = true;
              };
            };

            provision = {
              enable = true;

              datasources.settings = {
                apiVersion = 1;
                datasources = [
                  {
                    name = "Prometheus";
                    type = "prometheus";
                    access = "proxy";
                    url = "https://prometheus.${config.host.networking.domainName}";
                    isDefault = true;
                    jsonData = {
                      basicAuth = true;
                      basicAuthUser = "admin";
                    };
                    secureJsonData = {
                      basicAuthPassword = "$__file{${config.age.secrets.Prometheus_ruwusch-pw.path}}";
                    };
                  }
                ];
              };

              dashboards = {
                # TODO: Declare some dashboards here
              };

            };
          };
        };
      }
    )
  ];
}
