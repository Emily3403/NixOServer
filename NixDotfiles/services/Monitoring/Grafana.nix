{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.grafana;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 11;
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
      file = ../../secrets/${config.host.name}/Monitoring/Grafana/admin-pw.age;
      owner = "grafana";
    };

    age.secrets.Grafana_secret-key = {
      file = ../../secrets/${config.host.name}/Monitoring/Grafana/secret-key.age;
      owner = "grafana";
    };

  };


  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "grafana";
        containerPort = 3000;
        postgresqlName = "grafana";

        user.uid = 196;
        isSystemUser = true;

        bindMounts = {
          "/var/lib/grafana/" = { hostPath = "${cfg.dataDir}/grafana"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${cfg.dataDir}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.Grafana_admin-pw.path}".hostPath = config.age.secrets.Grafana_admin-pw.path;
          "${config.age.secrets.Grafana_secret-key.path}".hostPath = config.age.secrets.Grafana_secret-key.path;
          "${config.age.secrets.Prometheus_nixie.path}".hostPath = config.age.secrets.Prometheus_nixie.path;
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

              "auth.generic_oauth" = {
                enabled = true;
                name = "Keycloak";

                allow_sign_up = true;
                auto_login = true;
                use_pkce = true;
                skip_org_role_sync = true;

                client_id = "Grafana";
                scopes = "openid email profile";
                email_attribute_path = "email";
                login_attribute_path = "preferred_username";
                name_attribute_path = "name";

                auth_url = "https://kc.ruwusch.de/realms/Super-Realm/protocol/openid-connect/auth";
                token_url = "https://kc.ruwusch.de/realms/Super-Realm/protocol/openid-connect/token";
                signout_redirect_url = "https://kc.ruwusch.de/realms/Super-Realm/protocol/openid-connect/logout?post_logout_redirect_uri=https%3A%2F%2F${cfg.subdomain}.${config.host.networking.domainName}%2Flogin";
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
                    isDefault = false; # TODO: This doesn't quite work yet

                    jsonData = {
                      basicAuth = true;
                      basicAuthUser = "admin";

                      timeInterval = "5s";
                      queryTimeout = "500s";
                      prometheusType = "Prometheus";
                    };

                    secureJsonData = {
                      basicAuthPassword = "$__file{${config.age.secrets.Prometheus_nixie.path}}";
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
