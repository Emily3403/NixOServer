{ pkgs, config, lib, ... }: {
  systemd.tmpfiles.rules = [
    "d /data 0755 root root"
    "a /data - - - - d:u:backup:rX"
    "a /data - - - - u:backup:rX"
  ];

  systemd.services.backup-postgres = {
    description = "Backup all PostgreSQL containers";
    wantedBy = [ "multi-user.target" ];
    path = [ "/run/current-system/sw" ];
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
      RandomizedDelaySec = 10;
    };
  };

#  security.wrappers = {
#    "rsync" = {
#      owner = "backup";
#      group = "backup";
#      capabilities = "cap_dac_read_search+ep";
#      source = "${pkgs.rsync.out}/bin/rsync";
#    };
#  };
}