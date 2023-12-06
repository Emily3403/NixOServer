{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Borg"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/borg/ 0750 borg borg"
  ];

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib;
        name = "borg";
        containerIP = "192.168.7.106";
        containerPort = 80;

        imports = [ ../../users/services/borg.nix ];

        bindMounts = {
          "/var/lib/borgbackup/" = { hostPath = "${DATA_DIR}/borg"; isReadOnly = false; };
          "${config.age.secrets.Borg_Encrytpion_Nixie.path}" = { hostPath = config.age.secrets.Borg_Encrytpion_Nixie.path; };
          "${config.age.secrets.Duplicati_SSHKey_Nixie.path}" = { hostPath = config.age.secrets.Duplicati_SSHKey_Nixie.path; };
        };

        cfg = {
          services.borgbackup.jobs.nixie = {
            repo = "root@130.149.220.242:/borg";
            paths = "/";
            startAt = "*-*-* 04:00:00";
            inhibitsSleep = true;

            encryption = {
              mode = "keyfile";
              passCommand = "cat ${config.age.secrets.Borg_Encrytpion_Nixie.path}";
            };

            #            prune.keep = {
            #              within = "7d";
            #            };
            extraCreateArgs = "--verbose";

            environment = { BORG_RSH = "ssh -i ${config.age.secrets.Duplicati_SSHKey_Nixie.path}"; };
          };
        };

      }
    )
  ];
}
