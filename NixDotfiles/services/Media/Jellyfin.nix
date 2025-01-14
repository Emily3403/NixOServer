{ pkgs, pkgs-unstable, config, lib, utils, ... }:
let
  cfg = config.host.services.jellyfin;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 9;
  users = [ "Emily" "Carsten" "Buddy" "Shalin" "Martin" "Jannes" "Hendrik" ];
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

    age.secrets.Prometheus_Jellyfin-exporter = mkIf cfg.enableExporter {
      file = ../../secrets/nixie/Monitoring/Exporters/${config.host.name}/Jellyfin.age;
      owner = "root";
    };

    users.groups.video.members = [ "jellyfin" ];
    users.groups.render.members = [ "jellyfin" ];

    services.nginx.virtualHosts."${config.host.networking.monitoringDomain}" = mkIf cfg.enableExporter (utils.makeNginxMetricConfig "jellyfin" "127.0.0.1" "9741");

    environment.systemPackages = [
      pkgs-unstable.cargo  # We always want the most up-to-date cargo
      pkgs-unstable.rustc
      pkgs.mold
      pkgs.clang
      pkgs.devenv
    ];
  };

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "jellyfin";
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

    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        enable = false;
        dataDir = cfg.dataDir;
        fqdn = config.host.networking.monitoringDomain;

        name = "jellyfin-exporter";
        image = "drkhsh/jellyfin-exporter:latest";
        containerID = 26;

        containerPort = 9027;
        nginxLocation = "/jellyfin-metrics";
        nginxProxyPassLocation = "/metrics";

        environment.JELLYFIN_BASEURL = "https://${cfg.subdomain}.${config.host.networking.domainName}";
        environmentFiles = [ config.age.secrets.Prometheus_Jellyfin-exporter.path ];
      }
    )
  ];
}
