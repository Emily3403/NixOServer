{ pkgs, inputs, config, lib, ... }:
let

  cfg = config.host.services.firefly-iii;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 31;
  importerContainerID = 32;
  fqdn = "${config.host.services.firefly-iii.subdomain}.${config.host.networking.domainName}";

  commonConf = {
    APP_ENV = "production";
    APP_URL = "https://${fqdn}";
    TRUSTED_PROXIES = toString config.host.networking.containerHostIP;
    LOG_CHANNEL = "stdout";
    LOG_LEVEL = "notice";
    TZ = config.host.networking.timeZone;
  };

  phpVirtualHostConfig = package: socket: {
    forceSSL = true;
    enableACME = true;
    root = "${package}/public";

    locations = {
      "/" = {
        tryFiles = "$uri $uri/ /index.php?$query_string";
        index = "index.php";
        extraConfig = "sendfile off;";
      };
      "~ \\.php$" = {
        extraConfig = ''
          include ${config.services.nginx.package}/conf/fastcgi_params ;
          fastcgi_param SCRIPT_FILENAME $request_filename;
          fastcgi_param modHeadersAvailable true; #Avoid sending the security headers twice
          fastcgi_pass unix:${socket};
          client_max_body_size 500M;

          # Importing data might take a while
          fastcgi_read_timeout 3600s;
          fastcgi_send_timeout 3600s;
          fastcgi_connect_timeout 3600s;
          proxy_read_timeout 3600s;
        '';
      };
    };
  };
in
{
  options.host.services.firefly-iii = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Firefly-III";
    };

    subdomain = mkOption {
      type = types.str;
      default = "money";
    };

    importer-subdomain = mkOption {
      type = types.str;
      default = "money-importer";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 firefly-iii"
      "d ${cfg.dataDir}/firefly-iii 0750 firefly-iii"
      "d ${cfg.dataDir}/firefly-iii-data-importer 0750 firefly-iii-data-importer"
      "d ${cfg.dataDir}/postgresql 0750 postgres"

      "d /run/firefly-iii 0750 firefly-iii nginx"
      "Z /run/firefly-iii - firefly-iii nginx"

      "d /run/firefly-iii-data-importer 0750 firefly-iii-data-importer nginx"
      "Z /run/firefly-iii-data-importer - firefly-iii-data-importer nginx"
    ];

    age.secrets.Firefly-III_app-key = {
      file = ../secrets/${config.host.name}/Firefly-III/app-key.age;
      owner = "firefly-iii";
    };

    age.secrets.Firefly-III_access-token = {
      file = ../secrets/${config.host.name}/Firefly-III/access-token.age;
      owner = "firefly-iii-data-importer";
    };

    services.nginx.virtualHosts.${fqdn} = phpVirtualHostConfig pkgs.firefly-iii "/run/firefly-iii/firefly-iii.sock";
    services.nginx.virtualHosts."${cfg.importer-subdomain}.${config.host.networking.domainName}" = phpVirtualHostConfig pkgs.firefly-iii-data-importer "/run/firefly-iii-data-importer/firefly-iii-data-importer.sock";

    # TODO: Look at https://github.com/kinduff/firefly_iii_exporter
#    age.secrets.Prometheus_Firefly-III-exporter = mkIf cfg.enableExporter {
#      file = ../secrets/nixie/Monitoring/Exporters/${config.host.name}/Firefly-III.age;
#      owner = "root";
#    };
#
#    services.nginx.virtualHosts."${config.host.networking.monitoringDomain}" = mkIf cfg.enableExporter (utils.makeNginxMetricConfig "firefly-iii" (utils.makeNixContainerIP containerID) "TODO");
  };

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config inputs lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "firefly-iii";
        containerPort = 80;
        makeNginxConfig = false;
        postgresqlName = "firefly-iii";

        isSystemUser = true;
        user.group = "nginx";
        group = {
          name = "nginx";
          gid = 60;
        };

        bindMounts = {
          "/var/lib/firefly-iii/" = { hostPath = "${cfg.dataDir}/firefly-iii"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${cfg.dataDir}/postgresql"; isReadOnly = false; };
          ${config.age.secrets.Firefly-III_app-key.path}.hostPath = config.age.secrets.Firefly-III_app-key.path;

          "/run/phpfpm/" = { hostPath = "/run/firefly-iii/"; isReadOnly = false; };
        };

        cfg = {
          services.firefly-iii = {
            enable = true;
            group = lib.mkForce "nginx";

            settings = commonConf // {
              APP_KEY_FILE = config.age.secrets.Firefly-III_app-key.path;

              DB_CONNECTION = "pgsql";
              DB_SOCKET = "/run/postgresql";
              DB_PORT = 5432;
              DB_DATABASE = "firefly-iii";

              SITE_OWNER = "seebeckemily3403@gmail.com";
              DEFAULT_LOCALE = "en_IE.UTF-8";  # Sensible data formats

              ENABLE_EXTERNAL_MAP = "true";
              APP_NAME = "Emily's Finances";
            };
          };
        };
      }
    )

    (
      import ./Container-Config/Nix-Container.nix {
        inherit config inputs lib pkgs;
        subdomain = cfg.subdomain;
        containerID = importerContainerID;

        name = "firefly-iii-data-importer";
        containerPort = 80;
        makeNginxConfig = false;

        isSystemUser = true;
        user.group = "nginx";
        group = {
          name = "nginx";
          gid = 60;
        };

        bindMounts = {
          "/var/lib/firefly-iii-data-importer/" = { hostPath = "${cfg.dataDir}/firefly-iii-data-importer"; isReadOnly = false; };
          ${config.age.secrets.Firefly-III_access-token.path}.hostPath = config.age.secrets.Firefly-III_access-token.path;

          "/run/phpfpm/" = { hostPath = "/run/firefly-iii-data-importer/"; isReadOnly = false; };
        };

        cfg = {
          services.phpfpm.pools.firefly-iii-data-importer.phpOptions = ''
            upload_max_filesize = "500M";
            max_execution_time = "3600";
          '';

          services.firefly-iii-data-importer = {
            enable = true;
            group = lib.mkForce "nginx";

            settings = commonConf // {
              FIREFLY_III_URL = "https://${fqdn}";
              EXPECT_SECURE_URL = "true";
              APP_NAME = "Emily's Importer";
              FIREFLY_III_CLIENT_ID = "5";

              # TODO
#              IGNORE_DUPLICATE_ERRORS = "true";
            };
          };
        };
      }
    )
  ];
}
