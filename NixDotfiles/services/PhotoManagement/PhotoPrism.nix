{ pkgs, pkgs-unstable, config, lib, ... }:
let DATA_DIR = "/data/PhotoPrism"; in
{
  systemd.tmpfiles.rules = [
    "d ${cfg.dataDir} 0750 photoprism"
    "d ${cfg.dataDir}/photoprism 0750 photoprism"
    "d ${cfg.dataDir}/mysql 0750 postgres"
  ];

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "photoprism";
        containerIP = "192.168.7.110";
        containerPort = 2342;

        imports = [ ../../users/services/photoprism.nix ];
        bindMounts = {
          "/var/lib/private/photoprism/" = { hostPath = "${cfg.dataDir}/photoprism"; isReadOnly = false; };
          "/var/lib/mysql" = { hostPath = "${cfg.dataDir}/mysql"; isReadOnly = false; };
          "${config.age.secrets.PhotoPrism.path}".hostPath = config.age.secrets.PhotoPrism.path;
        };

        # Allow uploads of big files
        additionalNginxConfig.extraConfig = "client_max_body_size 50G;";
        additionalNginxLocationConfig.proxyWebsockets = true;

        cfg = {
          services.photoprism = {
            enable = true;
            originalsPath = "/var/lib/private/photoprism/originals";
            address = "0.0.0.0";
            passwordFile = config.age.secrets.PhotoPrism.path;

            settings = {
              PHOTOPRISM_ADMIN_USER = "emily";
              PHOTOPRISM_DEFAULT_LOCALE = "en";
              PHOTOPRISM_DATABASE_DRIVER = "mysql";
              PHOTOPRISM_DATABASE_NAME = "photoprism";
              PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
              PHOTOPRISM_DATABASE_USER = "photoprism";
              PHOTOPRISM_SITE_URL = "https://photoprism.${config.host.networking.domainName}";
              PHOTOPRISM_SITE_TITLE = "PhotoPrism";
              PHOTOPRISM_UPLOAD_NSFW = "true";
            };

          };

          services.mysql = {
            enable = true;
            package = pkgs.mariadb;
            ensureDatabases = [ "photoprism" ];
            ensureUsers = [ {
              name = "photoprism";
              ensurePermissions = {
                "photoprism.*" = "ALL PRIVILEGES";
              };
            } ];
          };

        };
      }
    )
  ];
}
