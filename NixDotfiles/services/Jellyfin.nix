{ pkgs, pkgs-unfree, config, lib, ... }:
let DATA_DIR = "/data/Jellyfin"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 jellyfin jellyfin"
    "d ${DATA_DIR}/jellyfin/ 0750 jellyfin jellyfin"
    "d ${DATA_DIR}/Media-Emily/ 0750 jellyfin jellyfin"
    "d ${DATA_DIR}/Media-Carsten/ 0750 jellyfin jellyfin"
    "d ${DATA_DIR}/Media-Shared/ 0750 jellyfin jellyfin"

    "d ${DATA_DIR}/Media-Shalin/ 0750 jellyfin jellyfin"
    "d ${DATA_DIR}/Media-Martin/ 0750 jellyfin jellyfin"
    "d ${DATA_DIR}/Media-Jannes/ 0750 jellyfin jellyfin"
  ];

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "jellyfin";
        containerIP = "192.168.7.109";
        containerPort = 8096;
        imports = [ ../users/services/jellyfin.nix ];
        enableHardwareTranscoding = true;

        additionalDomains = [ "kino" ];
        additionalNginxLocationConfig.proxyWebsockets = true;
        additionalNginxConfig.locations."/metrics".return = "403";

        additionalContainerConfig.forwardPorts = [
          { containerPort = 1900; hostPort = 1900; protocol = "udp"; }
          { containerPort = 7359; hostPort = 7359; protocol = "udp"; }
        ];

        bindMounts = {
          "/var/lib/jellyfin" = { hostPath = "${DATA_DIR}/jellyfin"; isReadOnly = false; };
          "/var/lib/data" = { hostPath = "/data/Transmission/data"; };

          "/var/lib/Media-Emily" = { hostPath = "${DATA_DIR}/Media-Emily"; };
          "/var/lib/Media-Carsten" = { hostPath = "${DATA_DIR}/Media-Carsten"; };
          "/var/lib/Media-Shared" = { hostPath = "${DATA_DIR}/Media-Shared"; };

          "/var/lib/Media-Shalin" = { hostPath = "${DATA_DIR}/Media-Shalin"; };
          "/var/lib/Media-Martin" = { hostPath = "${DATA_DIR}/Media-Martin"; };
          "/var/lib/Media-Jannes" = { hostPath = "${DATA_DIR}/Media-Jannes"; };
        };  # TODO: Factor people out into a for-lopp

        cfg.services.jellyfin = {
          enable = true;
          openFirewall = true;
        };
      }
    )
  ];
}
