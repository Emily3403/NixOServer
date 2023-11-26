let

  SUBDOMAIN = "TODO";
  CONTAINER_IP = "10.88.1.TODO";
  CONTAINER_PORT = "TODO";
  CONTAINER_VERSION = "TODO";
  DATA_DIR = "/data/TODO";

in

{ pkgs, config, lib, ...}: {

  imports = [
    ( import ./Container-Config/Nginx.nix { subdomain=SUBDOMAIN; containerIP=CONTAINER_IP; containerPort=CONTAINER_PORT; config=config; })
  ];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/TODO/ 0750 5000 5000"
  ];

  virtualisation.oci-containers.containers.youtrack = {
    image = "jetbrains/youtrack:${CONTAINER_VERSION}";  # TODO: This needs manual updating.
    ports = [ "127.0.0.1::${CONTAINER_PORT}" ];
    extraOptions = [ "--ip=${CONTAINER_IP}" "--userns=keep-id" ];

    volumes = [
      "${DATA_DIR}/data:/opt/youtrack/data"
      "${DATA_DIR}/conf:/opt/youtrack/conf"
      "${DATA_DIR}/logs:/opt/youtrack/logs"
      "${DATA_DIR}/backups:/opt/youtrack/backups"
    ];

  };
}