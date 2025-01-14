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
      "d ${cfg.dataDir} 0750 radarr"
      "d ${cfg.dataDir}/radarr 0750 radarr"
    ];
  };

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;

        name = "radarr";
        subdomain = cfg.subdomain;
        containerID = 17;
        containerPort = 7878;

        user.uid = 275;
        isSystemUser = true;

        bindMounts = {
          "/var/lib/radarr/" = { hostPath = "${cfg.dataDir}/radarr"; isReadOnly = false; };
        };

        cfg = {
          services.radarr = {
            enable = true;
            dataDir = "/var/lib/radarr";
          };
        };
      }
    )
  ];
}
