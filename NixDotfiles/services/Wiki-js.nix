{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Wiki-js"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/postgresql 0755 postgres"
    "d ${DATA_DIR}/wiki-js 0755 wiki-js"
  ];

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib;
        name = "wiki-js";
        subdomain = "wiki";
        containerIP = "192.168.7.102";
        containerPort = 3000;

        imports = [ ../users/services/wiki-js.nix ];
        bindMounts = {
          "/var/lib/wiki-js/" = { hostPath = "${DATA_DIR}/wiki-js"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${DATA_DIR}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.WikiJs_SSHKey.path}".hostPath = config.age.secrets.WikiJs_SSHKey.path;
        };

        cfg = {
          imports = [ (import ./Container-Config/Postgresql.nix { name = "wiki-js"; pkgs = pkgs; }) ];

          services.wiki-js = {
            enable = true;

            settings.db = {
#              db = "wiki-js";
              host = "/run/postgresql";
              user = "wiki-js";
            };
          };
        };
      }
    )
  ];
}
