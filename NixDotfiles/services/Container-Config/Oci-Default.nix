{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/TODO"; in
{

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs;

        enable = true;
        name = "TODO";
        image = "TODO";
        dataDir = cfg.dataDir;

        subdomain = "TODO";
        containerIP = "10.88.TODO.1";
        containerPort = 80;
        environment = { };
        environmentFiles = [ config.age.secrets.TODO.path ];

        volumes = [
          "${cfg.dataDir}/TODO:/TODO"
        ];
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${cfg.dataDir} 0750 5000 5000"
    "d ${cfg.dataDir}/TODO/ 0750 5000 5000"
  ];
}
