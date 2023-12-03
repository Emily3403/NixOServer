{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/YouTrack"; in
{

  imports = [(
      import ./Container-Config/Oci-Container.nix {
        inherit config lib;
        name = "youtrack";
        image = "jetbrains/youtrack:2023.2.21228";

        subdomain = "ticket";
        containerIP = "10.88.1.1";
        containerPort = 8080;

        volumes = [
          "${DATA_DIR}/data:/opt/youtrack/data"
          "${DATA_DIR}/conf:/opt/youtrack/conf"
          "${DATA_DIR}/logs:/opt/youtrack/logs"
          "${DATA_DIR}/backups:/opt/youtrack/backups"
        ];
      }
  )];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/data/ 0750 13001 13001"
    "d ${DATA_DIR}/conf/ 0750 13001 13001"
    "d ${DATA_DIR}/logs/ 0750 13001 13001"
    "d ${DATA_DIR}/backups/ 0750 13001 13001"
  ];
}
