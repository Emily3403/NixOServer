{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.youtrack;
  inherit (lib) mkIf mkOption types;
in
{

  options.host.services.youtrack = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/YouTrack";
    };

    subdomain = mkOption {
      type = types.str;
      default = "ticket";
    };
  };

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        name = "youtrack";
        image = "jetbrains/youtrack:2024.3.55417";
        dataDir = cfg.dataDir;

        subdomain = cfg.subdomain;
        containerID = 1;
        containerPort = 8080;

        volumes = [
          "${cfg.dataDir}/data:/opt/youtrack/data"
          "${cfg.dataDir}/conf:/opt/youtrack/conf"
          "${cfg.dataDir}/logs:/opt/youtrack/logs"
          "${cfg.dataDir}/backups:/opt/youtrack/backups"
        ];
      }
    )
  ];

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 13001 13001"
      "d ${cfg.dataDir}/data/ 0750 13001 13001"
      "d ${cfg.dataDir}/conf/ 0750 13001 13001"
      "d ${cfg.dataDir}/logs/ 0750 13001 13001"
      "d ${cfg.dataDir}/backups/ 0750 13001 13001"
    ];
  };
}
