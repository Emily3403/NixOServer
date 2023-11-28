let

  SUBDOMAIN = "sync";
  CONTAINER_IP = "192.168.7.105";
  CONTAINER_PORT = 8080;
  DATA_DIR = "/data/Syncthing";

in

{ pkgs, config, lib, ... }: {
  imports = [ ../users/services/syncthing.nix ];

  # TODO: Migrate this to a function
  services.nginx.virtualHosts = {
    "${SUBDOMAIN}.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://${CONTAINER_IP}:${toString CONTAINER_PORT}/";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/syncthing 0755 syncthing"
  ];

  containers.syncthing = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = config.containerHostIP;
    localAddress = "${CONTAINER_IP}";

    bindMounts = {
      "/var/lib/syncthing/" = { hostPath = "${DATA_DIR}/syncthing"; isReadOnly = false; };
    };

    config = { pkgs, config, lib, ... }: {
      networking.firewall.allowedTCPPorts = [ CONTAINER_PORT ];
      imports = [
        ../users/root.nix
        ../users/services/syncthing.nix
        ../system.nix
      ];

      services.syncthing = {
        enable = true;

        overrideFolders = false;
        guiAddress = "0.0.0.0:${toString CONTAINER_PORT}";
        openDefaultPorts = true;

        user = "syncthing";
        group = "syncthing";

        devices = {
          nyaa = {
            id = "6OGY4LN-KQ3XE33-X5QIWVN-IUZ6F5E-7DNZHQ6-7DVBR6G-FIVWZPC-GMKYXQN";
            introducer = true;
            autoAcceptFolders = true;
          };

          UwU = {
            id = "3P2KUWI-C7GCARO-LAHCSIB-M3O7LE7-X4RFYQ6-7HNFJ7I-Y72NUOV-3HNYAAA";
            introducer = true;
            autoAcceptFolders = true;
          };
        };
      };

    };
  };
}
