{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Transmission"; in
{

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        name = "transmission";
        image = "haugene/transmission-openvpn:latest";
        dataDir = cfg.dataDir;

        containerIP = "10.88.2.1";
        containerPort = 9091;
        additionalDomains = [ "transui" ];

        additionalContainerConfig.extraOptions = [ "--cap-add=NET_ADMIN" "--device=/dev/net/tun" ];
        environment = {
          PUID = toString config.users.users.jellyfin.uid;
          PGID = toString config.users.groups.jellyfin.gid;
        };
        environmentFiles = [ config.age.secrets.Transmission_EnvironmentFile.path ];

        volumes = [
          "${cfg.dataDir}/data:/data"
          "${cfg.dataDir}/config:/config"
        ];
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${cfg.dataDir}/ 0750 jellyfin jellyfin"
    "d ${cfg.dataDir}/data/ 0750 jellyfin jellyfin"
    "d ${cfg.dataDir}/config/ 0750 jellyfin jellyfin"
  ];
}
