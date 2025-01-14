{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.grafana;
  inherit (lib) mkIf mkOption types;
in
{

  options.host.services.grafana = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Grafana";
    };

    subdomain = mkOption {
      type = types.str;
      default = "status";
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 grafana grafana"
      "d ${cfg.dataDir}/grafana 0750 grafana grafana"
      "d ${cfg.dataDir}/postgresql 0750 postgres postgres"
    ];

    age.secrets.Grafana_admin-pw = {
      file = ../../secrets/${config.host.name}/Monitoring/Grafana-admin-pw.age;
      owner = "grafana";
    };

    age.secrets.Grafana_secret-key = {
      file = ../../secrets/${config.host.name}/Monitoring/Grafana-secret-key.age;
      owner = "grafana";
    };

  };


  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;

        name = "grafana";
        subdomain = cfg.subdomain;
        containerID = 11;
        containerPort = 3000;
        postgresqlName = "grafana";

        user.uid = 196;
        isSystemUser = true;

        bindMounts = {
          "/var/lib/grafana/" = { hostPath = "${cfg.dataDir}/grafana"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${cfg.dataDir}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.Grafana_admin-pw.path}".hostPath = config.age.secrets.Grafana_admin-pw.path;
          "${config.age.secrets.Grafana_secret-key.path}".hostPath = config.age.secrets.Grafana_secret-key.path;
          "${config.age.secrets.Prometheus_nixie-pw.path}".hostPath = config.age.secrets.Prometheus_nixie-pw.path;
        };

        cfg = {
          services.grafana = {
            enable = true;
            declarativePlugins = null;

            settings = {
              server = {
                root_url = "https://${cfg.subdomain}.${config.host.networking.domainName}";
                domain = "${cfg.subdomain}.${config.host.networking.domainName}";
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
                    url = "https://${config.host.services.prometheus.subdomain}.${config.host.networking.domainName}";
                    isDefault = true;
                    jsonData = {
                      basicAuth = true;
                      basicAuthUser = "admin";
                    };
                    secureJsonData = {
                      basicAuthPassword = "$__file{${config.age.secrets.Prometheus_nixie-pw.path}}";
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
