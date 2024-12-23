{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/TODO"; in
{

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        name = "TODO";
        image = "TODO";
        dataDir = DATA_DIR;

        subdomain = "TODO";
        containerIP = "10.88.TODO.1";
        containerPort = 80;
        environment = { };
        environmentFiles = [ config.age.secrets.TODO.path ];

        volumes = [
          "${DATA_DIR}/TODO:/TODO"
        ];
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 5000 5000"
    "d ${DATA_DIR}/TODO/ 0750 5000 5000"
  ];
}
