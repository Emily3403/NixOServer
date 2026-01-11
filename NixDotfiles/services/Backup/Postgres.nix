{ pkgs, inputs, config, lib, ... }: {
  systemd.services.backup-postgres = {
    description = "Backup all PostgreSQL containers";
    wantedBy = [ "multi-user.target" ];
    path = [ "/run/current-system/sw" ];
    restartIfChanged = false;

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "/root/NixOServer/FunctionScripts/dump_postgres.sh";
    };
  };

  systemd.timers.backup-postgres = {
    description = "Backup all PostgreSQL containers";
    enable = true;
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 4:00:00";
      Persistent = true;
      RandomizedDelaySec = 100;
    };
  };
}
