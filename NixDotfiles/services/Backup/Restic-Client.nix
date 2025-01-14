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

    backup-host = mkOption {
      type = types.str;
      default = "mar-restic.inet.tu-berlin.de";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
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

    services.restic.backups = {
      mar = {
        passwordFile = config.age.secrets.Restic_password.path;
        environmentFile = config.age.secrets.Restic_env.path;
        repository = "rest:https://${cfg.backup-host}/emily-${config.host.name}";

        initialize = true;
        paths = [ "/data" ];
        backupPrepareCommand = "/root/NixOServer/FunctionScripts/dump_postgres.sh";

        timerConfig = {
# Run every day between 23:00 and 5:00, depending on the random delay
          OnCalendar = "23:00";
          Persistent = true;
          RandomizedDelaySec = "6h";
        };
      };
    };

    systemd.services.restic-backups-mar.path = [ "/run/current-system/sw/" ];
  };
}
