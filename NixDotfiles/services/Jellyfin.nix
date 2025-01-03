{ pkgs, pkgs-unfree, config, lib, ... }:
let DATA_DIR = "/data/Jellyfin"; in
{
  systemd.tmpfiles.rules = [
    "d ${cfg.dataDir} 0750 jellyfin jellyfin"
    "d ${cfg.dataDir}/jellyfin/ 0750 jellyfin jellyfin"
    "d ${cfg.dataDir}/Media-Emily/ 0750 jellyfin jellyfin"
    "d ${cfg.dataDir}/Media-Carsten/ 0750 jellyfin jellyfin"
    "d ${cfg.dataDir}/Media-Shared/ 0750 jellyfin jellyfin"

    "d ${cfg.dataDir}/Media-Shalin/ 0750 jellyfin jellyfin"
    "d ${cfg.dataDir}/Media-Martin/ 0750 jellyfin jellyfin"
    "d ${cfg.dataDir}/Media-Jannes/ 0750 jellyfin jellyfin"
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
          "/var/lib/jellyfin" = { hostPath = "${cfg.dataDir}/jellyfin"; isReadOnly = false; };
          "/var/lib/data" = { hostPath = "/data/Transmission/data"; };

          "/var/lib/Media-Emily" = { hostPath = "${cfg.dataDir}/Media-Emily"; };
          "/var/lib/Media-Carsten" = { hostPath = "${cfg.dataDir}/Media-Carsten"; };
          "/var/lib/Media-Shared" = { hostPath = "${cfg.dataDir}/Media-Shared"; };

          "/var/lib/Media-Shalin" = { hostPath = "${cfg.dataDir}/Media-Shalin"; };
          "/var/lib/Media-Martin" = { hostPath = "${cfg.dataDir}/Media-Martin"; };
          "/var/lib/Media-Jannes" = { hostPath = "${cfg.dataDir}/Media-Jannes"; };
        };  # TODO: Factor people out into a for-lopp

        cfg.services.jellyfin = {
          enable = true;
          openFirewall = true;
        };
      }
    )
  ];
}
