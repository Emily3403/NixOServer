{ pkgs, pkgs-unstable, config, lib, ... }:
let
  cfg = config.host.services.sonarr;
  inherit (lib) mkIf mkOption types;
in
{
  options.host.services.sonarr = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Sonarr";
    };

    subdomain = mkOption {
      type = types.str;
      default = "sonarr";
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 sonarr"
      "d ${cfg.dataDir}/sonarr 0750 sonarr"
    ];

  };

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs;

        name = "sonarr";
        subdomain = cfg.subdomain;
        containerID = 16;
        containerPort = 8989;

        user.uid = 274;
        isSystemUser = true;

        bindMounts = {
          "/var/lib/sonarr/" = { hostPath = "${cfg.dataDir}/sonarr"; isReadOnly = false; };
        };

        cfg = {
          nixpkgs.config.permittedInsecurePackages = [
            "aspnetcore-runtime-6.0.36"
            "aspnetcore-runtime-wrapped-6.0.36"
            "dotnet-sdk-6.0.428"
            "dotnet-sdk-wrapped-6.0.428"
          ];

          services.sonarr = {
            enable = true;
            dataDir = "/var/lib/sonarr";
            package = pkgs-unstable.sonarr;
          };
        };
      }
    )
  ];
}
