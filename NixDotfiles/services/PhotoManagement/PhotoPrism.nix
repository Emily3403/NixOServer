{ pkgs, pkgs-unstable, config, lib, ... }:
let DATA_DIR = "/data/PhotoPrism"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0755 photoprism"
    "d ${DATA_DIR}/photoprism 0755 photoprism"
    "d ${DATA_DIR}/mysql 0755 postgres"
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
          "/var/lib/private/photoprism/" = { hostPath = "${DATA_DIR}/photoprism"; isReadOnly = false; };
          "/var/lib/mysql" = { hostPath = "${DATA_DIR}/mysql"; isReadOnly = false; };
          "${config.age.secrets.PhotoPrism.path}".hostPath = config.age.secrets.PhotoPrism.path;
        };

        # Allow uploads of big files
        additionalNginxConfig.extraConfig = "client_max_body_size 200G;";

        cfg = {
          services.photoprism = {
            enable = true;
            storagePath = "/var/lib/private/photoprism";
            originalsPath = "/var/lib/private/photoprism/originals";
            address = "0.0.0.0";
            passwordFile = config.age.secrets.PhotoPrism.path;

            settings = {
              PHOTOPRISM_ADMIN_USER = "admin";
              PHOTOPRISM_DEFAULT_LOCALE = "en";
              PHOTOPRISM_DATABASE_DRIVER = "mysql";
              PHOTOPRISM_DATABASE_NAME = "photoprism";
              PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
              PHOTOPRISM_DATABASE_USER = "photoprism";
              PHOTOPRISM_SITE_URL = "https://photoprism.ruwusch.de";
              PHOTOPRISM_SITE_TITLE = "PhotoPrism";
            };

          };

          # Somehow, networking breaks in the default config. If `DynamicUser` is disabled it works. TODO: Further investigation
          systemd.services.photoprism.serviceConfig = {
            DynamicUser = lib.mkForce false;
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
