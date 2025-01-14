{ pkgs, config, lib, utils, ... }:
let
  users = [ "Emily" "Carsten" "Buddy" "Shalin" "Martin" "Jannes" "Hendrik" ];

  cfg = config.host.services.jellyfin;
  inherit (lib) mkIf mkOption types;
in
{
  options.host.services.jellyfin = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Jellyfin";
    };

    subdomain = mkOption {
      type = types.str;
      default = "kino";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 jellyfin jellyfin"
      "d ${cfg.dataDir}/jellyfin/ 0750 jellyfin jellyfin"
    ] ++
    map (user: "d ${cfg.dataDir}/Media-${user}/ 0750 jellyfin jellyfin") users;

    users.groups.video.members = [ "jellyfin" ];
    users.groups.render.members = [ "jellyfin" ];

#    services.nginx.virtualHosts."${config.host.name}.status.${config.host.networking.domainName}" = {
#      locations."/jellyfin-metrics-1" = {
#        proxyPass = "http://jellyfin-exporter:9850";
#      };
#    };
  };

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;

        name = "jellyfin";
        subdomain = cfg.subdomain;
        containerID = 9;
        containerPort = 8096;

        user.extraGroups = [ "render" "video" ];
        isSystemUser = true;
        enableHardwareTranscoding = true;

        additionalNginxConfig.locations = {
          "/socket".proxyWebsockets = true;
          "/health".return = "403";
          "/metrics".return = "403";
        };

        bindMounts = {
          "/var/lib/jellyfin" = { hostPath = "${cfg.dataDir}/jellyfin"; isReadOnly = false; };
          "/var/lib/data" = { hostPath = "/data/Transmission/data"; };
        } // # Will generate /var/lib/Media-Emily = { hostPath = cfg.dataDir/Media-Emily };
        builtins.listToAttrs (map (user: { name = "/var/lib/Media-${user}"; value = { hostPath = "${cfg.dataDir}/Media-${user}"; }; }) users);

        cfg = {
          services.jellyfin = {
            enable = true;
            openFirewall = true;
          };

          users.groups.video.members = [ "jellyfin" ];
          users.groups.render.members = [ "jellyfin" ];
        };
      }
    )
#    (
#      import ../Container-Config/Oci-Container.nix {
#        inherit config lib pkgs;
#
#        enable = true;
#        name = "jellyfin-exporter";
#        image = "drkhsh/jellyfin-exporter";
#        dataDir = cfg.dataDir;
#
#        subdomain = "${config.host.name}.status";
#        nginxLocation = "/jellyfin-metrics-1";
#        containerID = 19;
#        containerPort = 9850;
#
#        environmentFiles = mkIf cfg.enableExporter [ config.age.secrets.jellyfin_Exporter-environment.path ];
#        additionalContainerConfig.cmd = [
#          "--jellyfin.address=https://${cfg.subdomain}.${config.host.networking.domainName}"
#          "--jellyfin.apiKey=$jellyfin_API_KEY"
#        ];
#
#      }
#    )
  ];
}
