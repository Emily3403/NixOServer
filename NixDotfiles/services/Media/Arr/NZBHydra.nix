{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.nzbhydra;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 20;
in
{
  options.host.services.nzbhydra = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/NZBHydra";
    };

    subdomain = mkOption {
      type = types.str;
      default = "nzbhydra";
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 jellyfin"
      "d ${cfg.dataDir}/nzbhydra2 0750 jellyfin"
    ];
  };

  imports = [
    (
      import ../../Container-Config/Nix-Container.nix {
        inherit config lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "nzbhydra";
        containerPort = 5076;
        bindMounts = { "/var/lib/nzbhydra2/" = { hostPath = "${cfg.dataDir}/nzbhydra2"; isReadOnly = false; }; };

        cfg = {
          services.nzbhydra2.enable = true;

          systemd.services.nzbhydra2.serviceConfig.user = lib.mkForce "jellyfin";
          systemd.services.nzbhydra2.serviceConfig.group = lib.mkForce "jellyfin";
          systemd.services.nzbhydra2.serviceConfig.ExecStart = lib.mkForce "${config.services.nzbhydra2.package}/bin/nzbhydra2 --host 0.0.0.0 --nobrowser --datafolder '${config.services.nzbhydra2.dataDir}'";
        };
      }
    )
  ];
}
