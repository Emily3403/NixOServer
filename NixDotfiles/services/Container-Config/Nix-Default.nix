{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/TODO"; in
{
  systemd.tmpfiles.rules = [
    "d ${cfg.dataDir} 0750 TODO"
    "d ${cfg.dataDir}/TODO 0750 TODO"
    "d ${cfg.dataDir}/postgresql 0750 postgres"
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
          "/var/lib/postgresql" = { hostPath = "${cfg.dataDir}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.TODO.path}".hostPath = config.age.secrets.TODO.path;
        };

        cfg = { };
      }
    )
  ];
}
