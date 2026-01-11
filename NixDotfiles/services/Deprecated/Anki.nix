{ pkgs, inputs, config, lib, ... }:
let DATA_DIR = "/data/Anki"; in
{
  systemd.tmpfiles.rules = [
    #    "d ${cfg.dataDir} 0750 TODO"
    #    "d ${cfg.dataDir}/anki-sync-server 0750 TODO"
  ];

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "TODO";
        subdomain = "TODO";
        containerIP = "192.168.7.TODO";
        containerPort = 80;
        postgresqlName = "TODO";

        imports = [ ../users/services/TODO.nix ];
        bindMounts = {
          "/var/lib/TODO/" = { hostPath = "${cfg.dataDir}/TODO"; isReadOnly = false; };
          "${config.age.secrets.TODO.path}".hostPath = config.age.secrets.TODO.path;
        };

        cfg = { };
      }
    )
  ];
}
