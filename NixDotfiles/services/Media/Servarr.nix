{ pkgs, pkgs-unstable, config, lib, ... }:
let
  cfg = config.host.services.servarr;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 16;

  makeNginxConf = port: {
    forceSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://${utils.makeNixContainerIP containerID}:${toString port}";
  };
in
{
  options.host.services.servarr = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Servarr";
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 jellyfin"
      "d ${cfg.dataDir}/prowlarr 0750 jellyfin"

      "d ${cfg.dataDir}/radarr 0750 jellyfin"
      "d ${cfg.dataDir}/sonarr 0750 jellyfin"
      "d ${cfg.dataDir}/lidarr 0750 jellyfin"
      "d ${cfg.dataDir}/readarr 0750 jellyfin"
      "d ${cfg.dataDir}/whisparr 0750 jellyfin"
    ];

    services.nginx.virtualHosts = {
      "radarr.${config.host.networking.domainName}" = makeNginxConf 7878;
      "sonarr.${config.host.networking.domainName}" = makeNginxConf 8989;
      "lidarr.${config.host.networking.domainName}" = makeNginxConf 8686;
      "readarr.${config.host.networking.domainName}" = makeNginxConf 8787;
      "whisparr.${config.host.networking.domainName}" = makeNginxConf 6969;

      "prowlarr.${config.host.networking.domainName}" = makeNginxConf 9696;
      "flaresolverr.${config.host.networking.domainName}" = makeNginxConf 8191;
    };

  };

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "servarr";
        containerPort = 0;
        makeNginxConfig = false;

        isSystemUser = true;

        user = {
          name = "jellyfin";
          uid = 12009;
        };

        additionalPorts = [ 7878 8989 8686 8787 6969  9696 8191 ];

        bindMounts = {
          "/var/lib/data/" = { hostPath = "${config.host.services.transmission.dataDir}/data"; isReadOnly = false; };

          "/var/lib/radarr/" = { hostPath = "${cfg.dataDir}/radarr"; isReadOnly = false; };
          "/var/lib/sonarr/" = { hostPath = "${cfg.dataDir}/sonarr"; isReadOnly = false; };
          "/var/lib/lidarr/" = { hostPath = "${cfg.dataDir}/lidarr"; isReadOnly = false; };
          "/var/lib/readarr/" = { hostPath = "${cfg.dataDir}/readarr"; isReadOnly = false; };
          "/var/lib/whisparr/" = { hostPath = "${cfg.dataDir}/whisparr"; isReadOnly = false; };
        };

        cfg = let
          userconf = { user = "jellyfin"; group = "jellyfin"; };
          defconf = {
            enable = true;
            settings.auth = {
              AuthenticationRequired = "Enabled";
              AuthenticationMethod = "Basic";
            };
          };
        in {
          services.radarr = userconf // defconf // { dataDir = "/var/lib/radarr"; };
          services.sonarr = userconf // defconf // { dataDir = "/var/lib/sonarr"; };

          services.prowlarr = defconf;
          services.flaresolverr = {
            enable = true;
            package = pkgs-unstable.flaresolverr;
          };
        };
      }
    )
  ];
}
