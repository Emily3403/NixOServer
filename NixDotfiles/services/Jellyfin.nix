{ pkgs, pkgs-unfree, config, lib, ... }:
let
  users = [ "Emily" "Carsten" "Buddy" "Shalin" "Martin" "Jannes" ];

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

  };

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;

        name = "jellyfin";
        subdomain = cfg.subdomain;
        containerID = 9;
        containerPort = 8096;

        user.extraGroups = [ "render" "video" ];
        isSystemUser = true;
        enableHardwareTranscoding = true;

        additionalNginxConfig.locations = {
          "/".proxyWebsockets = true;
          "/metrics".return = "403";
        };

        bindMounts = {
          "/var/lib/jellyfin" = { hostPath = "${cfg.dataDir}/jellyfin"; isReadOnly = false; };
          "/var/lib/data" = { hostPath = "/data/Transmission/data"; };
        } //  # Will generate /var/lib/Media-Emily = { hostPath = cfg.dataDir/Media-Emily };
          builtins.listToAttrs ( map ( user: { name = "/var/lib/Media-${user}"; value = { hostPath = "${cfg.dataDir}/Media-${user}"; };  } ) users ) ;

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
  ];
}
