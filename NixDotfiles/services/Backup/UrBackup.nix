{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/UrBackup"; in
{

  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config;
        name = "urbackup";
        image = "uroni/urbackup-server";

        subdomain = "urbackup";
        containerIP = "10.88.4.1";
        containerPort = 55414;

        additionalOptions = [ "--device=/dev/zfs" ];

        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Europe/Berlin";
        };

        volumes = [
          "${DATA_DIR}/backups:/backups"
          "${DATA_DIR}/urbackup:/var/urbackup"

          "${config.age.secrets.Duplicati_SSHKey_Nixie.path}:${config.age.secrets.Duplicati_SSHKey_Nixie.path}"
        ];
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/backups/ 0750 1000 1000"
    "d ${DATA_DIR}/urbackup/ 0750 1000 1000"
  ];
}
