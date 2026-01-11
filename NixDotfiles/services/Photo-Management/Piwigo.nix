{ pkgs, inputs, config, lib, ... }:
let
  cfg = config.host.services.piwigo;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 30;
in
{
  options.host.services.piwigo = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Piwigo";
    };

    subdomain = mkOption {
      type = types.str;
      default = "piwigo";
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 5014 5014"
      "d ${cfg.dataDir}/config/ 0750 5014 5014"
      "d ${cfg.dataDir}/gallery/ 0750 5014 5014"
    ];

    age.secrets.Piwigo = {
      file = ../secrets/${config.host.name}/Piwigo.age;
      owner = "TODO";
    };

  };


  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs containerID;
        dataDir = cfg.dataDir;
        subdomain = cfg.subdomain;

        name = "piwigo";
        image = "linuxserver/piwigo:14.3.0";
        containerPort = 80;

        environment = {
          PUID = "11001";
          PGID = "11001";
        };

        mysqlEnvFile = config.age.secrets.Piwigo_Mariadb.path;

        volumes = [
          "${cfg.dataDir}/config:/config"
          "${cfg.dataDir}/gallery:/gallery"
        ];
      }
    )
  ];
}
