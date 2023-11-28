let

  SUBDOMAIN = "wiki";
  CONTAINER_IP = "192.168.7.102";
  CONTAINER_PORT = 3000;
  DATA_DIR = "/data/Wiki-js";

in

{ pkgs, config, lib, ... }: {
  imports = [ ../users/services/wiki-js.nix ];

  # TODO: Migrate this to a function
  services.nginx.virtualHosts = {
    "${SUBDOMAIN}.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://${CONTAINER_IP}:${toString CONTAINER_PORT}/";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/postgresql 0755 postgres"
    "d ${DATA_DIR}/wiki-js 0755 wiki-js"
  ];

  containers.wiki-js = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = config.containerHostIP;
    localAddress = "${CONTAINER_IP}";

    bindMounts = {
      "/var/lib/wiki-js/" = { hostPath = "${DATA_DIR}/wiki-js"; isReadOnly = false; };
      "/var/lib/postgresql" = { hostPath = "${DATA_DIR}/postgresql"; isReadOnly = false; };
      "${config.age.secrets.WikiJs_SSHKey.path}" = { hostPath = config.age.secrets.WikiJs_SSHKey.path; };
    };

    config = { pkgs, config, lib, ... }: {
      networking.firewall.allowedTCPPorts = [ CONTAINER_PORT ];
      imports = [
        ../users/root.nix
        ../users/services/wiki-js.nix
        ../system.nix
        (import ./Container-Config/Postgresql.nix { dbName = "wiki"; dbUser = "wiki-js"; pkgs = pkgs; })
      ];

      services.wiki-js = {
        enable = true;

        settings.db = {
          host = "/run/postgresql";
          user = "wiki-js";
        };
      };

    };
  };
}
