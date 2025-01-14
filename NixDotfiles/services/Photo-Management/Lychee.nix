{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.lychee;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 28;
in
{
  options.host.services.lychee = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Lychee";
    };

    subdomain = mkOption {
      type = types.str;
      default = "lychee";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 root"
      "d ${cfg.dataDir}/config 0750 11000"
      "d ${cfg.dataDir}/pictures 0750 11000"
    ];

    age.secrets.Lychee = {
      file = ../../secrets/${config.host.name}/Photo-Management/Lychee/Env.age;
      owner = "11000";
    };

    age.secrets.Lychee_Postgres = {
      file = ../../secrets/${config.host.name}/Photo-Management/Lychee/Postgres.age;
      owner = "11000";
    };
  };

  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs containerID;
        dataDir = cfg.dataDir;
        subdomain = cfg.subdomain;

        name = "lychee";
        image = "linuxserver/lychee:latest";
        containerPort = 80;

        environmentFiles = [ config.age.secrets.Lychee.path ];
        postgresEnvFile = config.age.secrets.Lychee_Postgres.path;
        additionalNginxConfig.extraConfig = "client_max_body_size 2G;";

        environment = {
          PUID = "11000";
          PGID = "11000";

          DB_CONNECTION = "pgsql";
          DB_HOST ="127.0.0.1";
          DB_PORT = "5432";
          DB_USERNAME = "postgres";
          DB_DATABASE = "lychee";
          DB_PASSWORD = ""; # TODO

          APP_NAME = "Memories";
          APP_URL = "https://${cfg.subdomain}.${config.host.networking.domainName}";
          TRUSTED_PROXIES = "10.88.0.1";
        };

        volumes = [
          "${cfg.dataDir}/config:/config"
          "${cfg.dataDir}/pictures:/pictures"
          "${cfg.dataDir}/imports:/imports"
        ];
      }
    )
  ];
}
