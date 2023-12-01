{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Restic"; in
{
  imports = [
    ../../users/services/restic.nix
  (
      import ../Container-Config/Nix-Container.nix {
        inherit config;
        name = "restic";
        subdomain = "restic";
        containerIP = "192.168.7.107";
        containerPort = 80;

        bindMounts = {
          "/var/lib/restic/" = { hostPath = "${DATA_DIR}/restic"; isReadOnly = false; };
          "${config.age.secrets.Borg_Encrytpion_Nixie.path}" = { hostPath = config.age.secrets.Borg_Encrytpion_Nixie.path; };
          "${config.age.secrets.Duplicati_SSHKey_Nixie.path}" = { hostPath = config.age.secrets.Duplicati_SSHKey_Nixie.path; };
        };

        cfg = {
          imports = [
            ../../users/services/restic.nix
          ];

          services.restic = {
            server.enable = true;
            server.extraFlags = [ "--no-auth" ];

#            backups.nixie = {
#
#            };
          };
        };
      }
    )
  ];


  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/restic/ 0750 root root"
  ];
}
