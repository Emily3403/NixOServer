{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Rsnapshot"; in
{
  imports = [
    ../../users/services/restic.nix
  (
      import ../Container-Config/Nix-Container.nix {
        inherit config;
        name = "rsnapshot";
        subdomain = "rsnapshot";
        containerIP = "192.168.7.108";
        containerPort = 80;

        bindMounts = {
          "/var/lib/backups" = { hostPath = "${DATA_DIR}/backups"; isReadOnly = false; };
        };

        cfg = {
          imports = [
            ../../users/root.nix
            ../../system.nix
            ../../users/services/restic.nix
          ];

          services.rsnapshot = {
            enable = true;

            extraConfig = ''
              snapshot_root	/var/lib/backups

              retain	daily	7
              retain	weekly	4
              retain	monthly	12

              backup	root@130.149.220.242:/root	nixie/
            '';

            cronIntervals = { daily = "00 4 * * *"; };
          };
        };
      }
    )
  ];


  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/backups/ 0750 root root"
  ];
}
