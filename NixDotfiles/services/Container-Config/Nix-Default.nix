{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/TODO"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/TODO 0755 TODO"
    "d ${DATA_DIR}/postgresql 0755 postgres"
  ];

  imports = [(
    import ./Container-Config/Nix-Container.nix {
      inherit config lib;
      name = "TODO";
      subdomain = "TODO";
      containerIP = "192.168.7.TODO";
      containerPort = 80;

      imports = [ ../users/services/TODO.nix ];
      bindMounts = {
        "/var/lib/TODO/" = { hostPath = "${DATA_DIR}/TODO"; isReadOnly = false; };
        "/var/lib/postgresql" = { hostPath = "${DATA_DIR}/postgresql"; isReadOnly = false; };
        "${config.age.secrets.TODO.path}".hostPath = config.age.secrets.TODO.path;
      };

      cfg = {

      };
    }
  )];
}
