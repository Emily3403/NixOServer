{ pkgs, pkgs-unstable, config, lib, ... }:
let
  cfg = config.host.services.prowlarr;
  utils = import ../../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 19;
in
{
  options.host.services.prowlarr = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Prowlarr";
    };

    subdomain = mkOption {
      type = types.str;
      default = "prowlarr";
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 jellyfin"
      "d ${cfg.dataDir}/prowlarr 0750 jellyfin"
    ];

  };

  imports = [
    (
      import ../../Container-Config/Nix-Container.nix {
        inherit config inputs lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "prowlarr";
        containerPort = 9696;
        isSystemUser = true;

        user = {
          name = "jellyfin";
          uid = 12009;
        };

        bindMounts = {
          "/var/lib/prowlarr/" = { hostPath = "${cfg.dataDir}/prowlarr"; isReadOnly = false; };
        };

        cfg = {
          services.prowlarr = {
            enable = true;
          };
        };
      }
    )
  ];
}
