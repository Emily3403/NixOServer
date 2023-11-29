{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Duplicati"; in
{

  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config;
        name = "duplicati";
        image = "linuxserver/duplicati:latest";

        subdomain = "duplicati";
        containerIP = "10.88.3.1";
        containerPort = 8200;

        environment = {
          PUID = "1000";
          PGID = "1000";
        };

        volumes = [
          "${DATA_DIR}/config:/config"
          "${DATA_DIR}/backups:/backups"
          "${DATA_DIR}/source:/source"

          "${config.age.secrets.Duplicati_SSHKey_Nixie.path}:${config.age.secrets.Duplicati_SSHKey_Nixie.path}"
        ];
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/config/ 0750 5000 5000"
    "d ${DATA_DIR}/backups/ 0750 1000 1000"
    "d ${DATA_DIR}/source/ 0750 1000 1000"

  ];
}
