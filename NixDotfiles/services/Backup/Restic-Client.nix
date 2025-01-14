{ pkgs, config, lib, ... }:
{
  age.secrets = {
    Restic_password = {
      file = ../secrets/${config.host.name}/Restic/password.age;
      owner = "root";
    };

    Restic_env = {
      file = ../secrets/${config.host.name}/Restic/env.age;
      owner = "root";
    };
  };

  services.restic.backups = {
    mar = {
      passwordFile = config.age.secrets."Restic_mar-pw".path;
      environmentFile = config.age.secrets."Restic_mar-env".path;
      repository = "rest:https://mar-restic.inet.tu-berlin.de/ruwusch-${config.host.name}";

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
}
