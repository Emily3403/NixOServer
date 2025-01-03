{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Wiki-js"; in
{
  systemd.tmpfiles.rules = [
    "d ${cfg.dataDir} 0750 wiki-js"
    "d ${cfg.dataDir}/postgresql 0750 postgres"
    "d ${cfg.dataDir}/wiki-js 0750 wiki-js"
  ];

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "wiki-js";
        subdomain = "wiki";
        containerIP = "192.168.7.102";
        containerPort = 3000;

        postgresqlName = "wiki-js";
        imports = [ ../users/services/wiki-js.nix ];
        bindMounts = {
          "/var/lib/wiki-js/" = { hostPath = "${cfg.dataDir}/wiki-js"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${cfg.dataDir}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.WikiJs_SSHKey.path}".hostPath = config.age.secrets.WikiJs_SSHKey.path;
        };

        cfg = {
          services.wiki-js = {
            enable = true;

            settings.db = {
              db = "wiki-js";
              host = "/run/postgresql";
              user = "wiki-js";
            };
          };
        };
      }
    )
  ];
}
