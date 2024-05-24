{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Affine"; in
{

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        name = "affine";
        image = "ghcr.io/toeverything/affine-graphql:beta";
        dataDir = DATA_DIR;

        containerIP = "10.88.5.1";
        containerPort = 443;
        environment = {
          NODE_OPTIONS = "--import=./scripts/register.js";
#          AFFINE_CONFIG_PATH = "/root/.affine/config";
          AFFINE_ADMIN_EMAIL = "seebeckemily3403@gmail.com";

          REDIS_SERVER_HOST = "127.0.0.1";
          AFFINE_SERVER_HOST = "affine.{config.domainName}";
          AFFINE_SERVER_HTTPS = "true";
          AFFINE_SERVER_PORT = "443";

          NODE_ENV = "production";
          TELEMETRY_ENABLE = "false";
        };
        environmentFiles = [ config.age.secrets.Affine_AdminPassword.path ];
        postgresEnvFile = config.age.secrets.Affine_Postgres.path;
        redisEnvFile = config.age.secrets.Affine_Redis.path;


        volumes = [
          "${DATA_DIR}/affine:/root/.affine/"
        ];
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 root root"
    "d ${DATA_DIR}/affine/ 0750 root root"
  ];
}
