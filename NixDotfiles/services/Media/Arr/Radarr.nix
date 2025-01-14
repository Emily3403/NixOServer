{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.radarr;
  inherit (lib) mkIf mkOption types;
in
{
  options.host.services.radarr = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Radarr";
    };

    subdomain = mkOption {
      type = types.str;
      default = "radarr";
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 jellyfin"
      "d ${cfg.dataDir}/radarr 0750 jellyfin"
    ];
  };

  imports = [
    (
      import ../../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;

        name = "radarr";
        subdomain = cfg.subdomain;
        containerID = 17;
        containerPort = 7878;

        user = {
          name = "jellyfin";
          uid = 12009;
        };
        isSystemUser = true;

        bindMounts = {
          "/var/lib/radarr/" = { hostPath = "${cfg.dataDir}/radarr"; isReadOnly = false; };
          "/var/lib/Movies/" = { hostPath = "${config.host.services.transmission.dataDir}/data/completed/Movies"; isReadOnly = false; };
        };

        cfg = {
          services.radarr = {
            enable = true;
            user = "jellyfin";
            group = "jellyfin";

            dataDir = "/var/lib/radarr";
          };
        };
      }
    )
  ];
}
