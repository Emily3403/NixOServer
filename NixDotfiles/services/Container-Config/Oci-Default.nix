{ pkgs, config, lib, ... }: {

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config;
        name = "TODO";
        image = "TODO";

        subdomain = "TODO";
        containerIP = "10.88.TODO.1";
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
