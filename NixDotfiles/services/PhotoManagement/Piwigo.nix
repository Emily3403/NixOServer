{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Piwigo"; in
{

  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;

        enable = true;
        name = "piwigo";
        image = "linuxserver/piwigo:14.3.0";
        dataDir = cfg.dataDir;

        containerIP = "10.88.4.1";
        containerPort = 80;
        environment = {
          PUID = "5014";
          PGID = "5014";
          TZ = "Europe/Berlin";
        };

        volumes = [
          "${cfg.dataDir}/config:/config"
          "${cfg.dataDir}/gallery:/gallery"
        ];
      }
    )
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;

        enable = true;
        name = "piwigo-mariadb";
        image = "linuxserver/mariadb:10.11.6";
        dataDir = cfg.dataDir;

        containerIP = "10.88.4.2";
        containerPort = 3306;
        makeNginxConfig = false;

        environment = {
          PUID = "5015";
          PGID = "5015";
          TZ = "Europe/Berlin";
        };
        environmentFiles = [ config.age.secrets.Piwigo_Mariadb.path ];

        volumes = [
          "${cfg.dataDir}/mariadb-config:/config"
        ];
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${cfg.dataDir} 0750 5014 5014"
    "d ${cfg.dataDir}/config/ 0750 5014 5014"
    "d ${cfg.dataDir}/gallery/ 0750 5014 5014"
    "d ${cfg.dataDir}/mariadb-config/ 0750 5015 5015"
  ];
}
