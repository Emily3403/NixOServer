{ pkgs, inputs, config, lib, ... }:
let

  cfg = config.host.services.paperless;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 34;
in
{
  options.host.services.paperless = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Paperless";
    };

    subdomain = mkOption {
      type = types.str;
      default = "paperless";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 paperless"
      "d ${cfg.dataDir}/paperless 0750 paperless"
      "d ${cfg.dataDir}/postgresql 0750 postgres"
    ];

    age.secrets.Paperless = {
      file = ../../secrets/${config.host.name}/Paperless/password.age;
      owner = "paperless";
    };

    age.secrets.Paperless_keycloak = {
      file = ../../secrets/${config.host.name}/Paperless/keycloak.age;
      owner = "paperless";
    };

    age.secrets.Prometheus_Paperless-exporter = mkIf cfg.enableExporter {
      file = ../../secrets/nixie/Monitoring/Exporters/${config.host.name}/Paperless.age;
      owner = "root";
    };
  };

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config inputs lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "paperless";
        containerPort = 28981;

        additionalNginxLocationConfig = {
          extraConfig = "client_max_body_size 1G;";
          proxyWebsockets = true;
        };

        user.uid = 315;
        isSystemUser = true;

        bindMounts = {
          "/var/lib/paperless/" = { hostPath = "${cfg.dataDir}/paperless"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${cfg.dataDir}/postgresql"; isReadOnly = false; };
          ${config.age.secrets.Paperless.path}.hostPath = config.age.secrets.Paperless.path;
          ${config.age.secrets.Paperless_keycloak.path}.hostPath = config.age.secrets.Paperless_keycloak.path;
        };

        cfg = {
          services.paperless = {
              enable = true;
              address = "0.0.0.0";
              passwordFile = config.age.secrets.Paperless.path;
              database.createLocally = true;
              exporter.enable = true;
              configureTika = true;

              settings = {
                PAPERLESS_URL = "https://${cfg.subdomain}.${config.host.networking.domainName}";
                PAPERLESS_FILENAME_FORMAT = "{{ created_year }}/{{ correspondent }}/{{ title }}";

                PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
              };
              environmentFile = config.age.secrets.Paperless_keycloak.path;
          };
        };
      }
    )

    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        enable = cfg.enableExporter;
        dataDir = cfg.dataDir;
        fqdn = config.host.networking.monitoringDomain;

        name = "paperless-exporter";
        image = "ghcr.io/hansmi/prometheus-paperless-exporter:v0.0.8";
        containerID = 35;

        containerPort = 8081;
        nginxLocation = "/paperless-metrics";
        nginxProxyPassLocation = "/metrics";

        environment = {

        };
        environmentFiles = [ config.age.secrets.Prometheus_Paperless-exporter.path ];
      }
    )
  ];
}
