{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/TODO"; in
{

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib;
        name = "TODO";
        image = "TODO";

        subdomain = "TODO";
        containerIP = "192.168.7.TODO";
        containerPort = 80;
        environmentFiles = [ config.age.secrets.TODO.path ];

        volumes = [
          "${DATA_DIR}/TODO:/TODO"
        ];
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/TODO/ 0750 5000 5000"
  ];
}
