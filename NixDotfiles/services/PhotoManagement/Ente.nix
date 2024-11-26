{ pkgs, pkgs-unstable, config, lib, ... }:
let DATA_DIR = "/data/Ente"; in
{

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 5000 5000"
    "d ${DATA_DIR}/logs/ 0750 5000 5000"
    "d ${DATA_DIR}/data/ 0750 5000 5000"
  ];

  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        name = "ente";
        image = "ente-io/server";
        dataDir = DATA_DIR;

        containerIP = "10.88.6.1";
        containerPort = 8080;
        environment = { ENTE_CREDENTIALS_FILE = "/credentials.yaml"; };
#        environmentFiles = [ config.age.secrets.Ente.path ];
        postgresEnvFile = config.age.secrets.EntePostgres.path;

        volumes = [
          "${DATA_DIR}/logs:/var/logs"
          "${DATA_DIR}/data:/data:ro"
          "${DATA_DIR}/museum.yaml:/museum.yaml:ro"
          "${DATA_DIR}/credentials.yaml:/credentials.yaml:ro"
        ];

        additionalContainers.ente-minio = {
          image = "minio/minio";
          extraOptions = [ "--pod=pod-ente" ];
#          environmentFiles = [ config.age.secrets.EnteMinio.path ];
          volumes = [ "${DATA_DIR}/minio-data:/data" ];
          entrypoint = ''server /data --address ":3200" --console-address ":3201"'';
          # TODO: How to provision minio
        };
      }
    )
  ];



  services.nginx.virtualHosts."photos.${config.domainName}" = {
    enableACME = true;
    forceSSL = true;
    root = pkgs-unstable.ente-web;
  };
}
