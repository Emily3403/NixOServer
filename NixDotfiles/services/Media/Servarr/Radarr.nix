{ pkgs, inputs, config, lib, ... }:
let
  cfg = config.host.services.radarr;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 17;
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
        inherit config inputs lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "radarr";
        containerPort = 7878;
        isSystemUser = true;

        user = {
          name = "jellyfin";
          uid = 12009;
        };

        bindMounts = {
          "/var/lib/radarr/" = { hostPath = "${cfg.dataDir}/radarr"; isReadOnly = false; };
          "/var/lib/data/" = { hostPath = "${config.host.services.transmission.dataDir}/data"; isReadOnly = false; };
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
