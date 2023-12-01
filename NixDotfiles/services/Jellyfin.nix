{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Jellyfin"; in
{
  imports = [
    ../users/services/jellyfin.nix
  (
      import ./Container-Config/Nix-Container.nix {
        inherit config;
        name = "jellyfin";
        subdomain = "jellyfin";
        containerIP = "192.168.7.109";
        containerPort = 8096;

        bindMounts = {
          "/var/lib/jellyfin" = { hostPath = "${DATA_DIR}/jellyfin"; isReadOnly = false; };
          "/var/lib/data" = { hostPath = "/data/Transmission/data"; isReadOnly = false; };
          "/var/lib/Media-Emily" = { hostPath = "${DATA_DIR}/Media-Emily"; isReadOnly = false; };
          "/var/lib/Media-Carsten" = { hostPath = "${DATA_DIR}/Media-Carsten"; isReadOnly = false; };
        };

        forwardPorts = [
          { containerPort = 1900; hostPort = 1900; protocol = "udp"; }
          { containerPort = 7359; hostPort = 7359; protocol = "udp"; }
        ];

        cfg = {
          imports = [
            ../users/root.nix
            ../system.nix
            ../users/services/jellyfin.nix
          ];

          services.jellyfin = {
            enable = true;
            openFirewall = true;
          };

        };
      }
    )
  ];


  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/jellyfin/ 0750 jellyfin jellyfin"
    "d ${DATA_DIR}/Media-Emily/ 0750 jellyfin jellyfin"
    "d ${DATA_DIR}/Media-Carsten/ 0750 jellyfin jellyfin"
  ];
}
