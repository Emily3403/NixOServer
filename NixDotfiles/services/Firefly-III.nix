{ pkgs, config, lib, ... }:
let

  cfg = config.host.services.firefly-iii;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  fqdn = "${config.host.services.firefly-iii.subdomain}.${config.host.networking.domainName}";

  containerID = 31;
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

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 firefly-iii"
      "d ${cfg.dataDir}/firefly-iii 0750 firefly-iii"
      "d ${cfg.dataDir}/postgresql 0750 postgres"

      "d /run/firefly-iii 0750 firefly-iii nginx"
      "Z /run/firefly-iii - firefly-iii nginx"
    ];

    age.secrets.Firefly-III = {
      file = ../secrets/${config.host.name}/Firefly-III.age;
      owner = "firefly-iii";
    };

    users.groups.nginx.members = [ "firefly-iii" ];

    services.nginx.virtualHosts.${fqdn} = {
      forceSSL = true;
      enableACME = true;
      root = "${pkgs.firefly-iii}/public";

      locations = {
        "/" = {
          tryFiles = "$uri $uri/ /index.php?$query_string";
          index = "index.php";
          extraConfig = ''
            sendfile off;
          '';
        };
        "~ \\.php$" = {
          extraConfig = ''
            include ${config.services.nginx.package}/conf/fastcgi_params ;
            fastcgi_param SCRIPT_FILENAME $request_filename;
            fastcgi_param modHeadersAvailable true; #Avoid sending the security headers twice
            fastcgi_pass unix:/run/firefly-iii/firefly-iii.sock;
          '';
        };
      };
    };

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
        inherit config lib pkgs containerID;
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
          ${config.age.secrets.Firefly-III.path}.hostPath = config.age.secrets.Firefly-III.path;

          "/run/phpfpm/" = { hostPath = "/run/firefly-iii/"; isReadOnly = false; };
        };

        cfg = {
          services.firefly-iii = {
            enable = true;
            group = lib.mkForce "nginx";

            settings = {
              APP_ENV = "production";
              APP_URL = "https://${fqdn}";
              TRUSTED_PROXIES = toString config.host.networking.containerHostIP;
              APP_KEY_FILE = config.age.secrets.Firefly-III.path;
              LOG_CHANNEL = "stdout";

              DB_CONNECTION = "pgsql";
              DB_SOCKET = "/run/postgresql";
              DB_PORT = 5432;
              DB_DATABASE = "firefly-iii";

              SITE_OWNER = "seebeckemily3403@gmail.com";
              DEFAULT_LOCALE = "en_IE.UTF-8";  # Sensible data formats
              TZ = config.host.networking.timeZone;

              ENABLE_EXTERNAL_MAP = "true";
              APP_NAME = "Emily's Finances";
            };
          };
        };
      }
    )
  ];
}
