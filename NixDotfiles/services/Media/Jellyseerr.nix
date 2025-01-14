{ pkgs, pkgs-unstable, config, lib, ... }:
let
  cfg = config.host.services.jellyseerr;
  inherit (lib) mkIf mkOption types;
in
{
  options.host.services.jellyseerr = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Jellyseerr";
    };

    subdomain = mkOption {
      type = types.str;
      default = "wishlist";
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 jellyseerr"
      "d ${cfg.dataDir}/jellyseerr 0750 jellyseerr"
    ];
  };

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;

        name = "jellyseerr";
        subdomain = cfg.subdomain;
        containerID = 15;
        containerPort = 5055;

        bindMounts = {
          "/var/lib/jellyseerr/" = { hostPath = "${cfg.dataDir}/jellyseerr"; isReadOnly = false; };
        };

        cfg.services.jellyseerr = {
          enable = true;
#          package = pkgs-unstable.jellyseerr;
        };
      }
    )
  ];
}
