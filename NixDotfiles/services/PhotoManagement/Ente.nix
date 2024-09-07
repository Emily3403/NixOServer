{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Ente"; in
{

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        name = "ente";
        image = "ente-io/server";

        containerIP = "10.88.6.1";
        containerPort = 8080;
        environment = { };
        environmentFiles = [ config.age.secrets.Ente.path ];
        postgresEnvFile = config.age.secrets.EntePostgres.path;

        volumes = [
          "${DATA_DIR}/TODO:/TODO"

          "${config.age.secrets.Ente.path}:${config.age.secrets.Ente.path}"
        ];

        additionalContainers.ente-minio = {
          image = "minio/minio";
          extraOptions = [ "--pod=pod-ente" ];
          environmentFiles = [ config.age.secrets.EnteMinio.path ];
          volumes = [ "${DATA_DIR}/minio-data:/data" ];
          entrypoint = ''server /data --address ":3200" --console-address ":3201"'';
          # TODO: How to provision minio
        };
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 5000 5000"
    "d ${DATA_DIR}/TODO/ 0750 5000 5000"
  ];

  services.nginx.virtualHosts."photos.${config.domainName}" = {
    enableACME = true;
    forceSSL = true;
    root = pkgs.ente-web;
  };
}
