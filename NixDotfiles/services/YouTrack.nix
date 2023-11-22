let

  SUBDOMAIN = "ticket";
  CONTAINER_IP = "10.88.1.1";
  CONTAINER_PORT = "8080";
  CONTAINER_VERSION = "2023.2.21228";
  DATA_DIR = "/data/YouTrack";

in

{ pkgs, config, lib, ...}: {

  services.nginx.virtualHosts = {
    "${SUBDOMAIN}.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://${CONTAINER_IP}:${CONTAINER_PORT}/";
    };
  };

  virtualisation.oci-containers.containers.youtrack = {
    image = "jetbrains/youtrack:${CONTAINER_VERSION}";  # TODO: This needs manual updating.
    ports = [ "127.0.0.1::${CONTAINER_PORT}" ];
    extraOptions = [ "--ip=${CONTAINER_IP}" "--userns=keep-id" ];

    volumes =
    [
      "${DATA_DIR}/data:/opt/youtrack/data"
      "${DATA_DIR}/conf:/opt/youtrack/conf"
      "${DATA_DIR}/logs:/opt/youtrack/logs"
      "${DATA_DIR}/backups:/opt/youtrack/backups"
    ];

  };

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/data/ 0750 13001 13001"
    "d ${DATA_DIR}/conf/ 0750 13001 13001"
    "d ${DATA_DIR}/logs/ 0750 13001 13001"
    "d ${DATA_DIR}/backups/ 0750 13001 13001"
  ];



}