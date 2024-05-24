{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Luk-Docs"; in
{

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        name = "luk-docs";
        image = "index.docker.io/lukburchard/docs";
        dataDir = DATA_DIR;


        additionalContainerConfig = {
          extraOptions = [ "--label=io.containers.autoupdate=registry" ];

          login = {
            registry = "index.docker.io";
            username = "lukburchard";
            passwordFile = config.age.secrets.LukDocs_EnvironmentFile.path;
          };
        };

        additionalNginxHostConfig."docs.lbb.sh" = {
          locations."/".proxyPass = "http://10.88.3.1:8080";
        };

        containerIP = "10.88.3.1";
        containerPort = 8080;
        environment = { };
        volumes = [ ];
      }
    )
  ];

  systemd.timers.podman-auto-update = {
      enable = true;
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = "*:0/10";
        Persistent = true;
        RandomizedDelaySec = 10;
      };
  };

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 root root"
  ];
}
