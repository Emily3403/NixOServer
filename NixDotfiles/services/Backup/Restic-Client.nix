{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.restic;
  inherit (lib) mkIf mkOption types;
in
{
  options.host.services.restic = {
    dataDir = mkOption {
      type = types.str;
      default = "/data";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };

    backup-host = mkOption {
      type = types.str;
      default = "emily-home.ruwusch.de";
    };

    repoName = mkOption {
      type = types.str;
      default = config.host.name;
    };
  };

  config = {
    age.secrets.Restic_password = {
      file = ../../secrets/${config.host.name}/Restic/password.age;
      owner = "root";
    };

    age.secrets.Restic_env = {
      file = ../../secrets/${config.host.name}/Restic/env.age;
      owner = "root";
    };

    services.restic.backups.${cfg.backup-host} = {
      passwordFile = config.age.secrets.Restic_password.path;
      environmentFile = config.age.secrets.Restic_env.path;
      repository = "rest:https://${cfg.backup-host}/${cfg.repoName}";

      initialize = true;
      paths = [ cfg.dataDir ];
      backupPrepareCommand = "/root/NixOServer/FunctionScripts/dump_postgres.sh";

      timerConfig = {
        # Start the backup every day between 0:00 and 3:00, depending on the random delay
        OnCalendar = "0:00";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
    };

    systemd.services."restic-backups-${cfg.backup-host}".path = [ "/run/current-system/sw/" ];
  };
}
