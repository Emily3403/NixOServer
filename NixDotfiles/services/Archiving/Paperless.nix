{ pkgs, config, lib, ... }:
let

  cfg = config.host.services.paperless;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 34;
in
{
  options.host.services.paperless = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Paperless";
    };

    subdomain = mkOption {
      type = types.str;
      default = "paperless";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 paperless"
      "d ${cfg.dataDir}/paperless 0750 paperless"
      "d ${cfg.dataDir}/postgresql 0750 postgres"
    ];

    age.secrets.Paperless = {
      file = ../secrets/${config.host.name}/Paperless.age;
      owner = "paperless";
    };

    age.secrets.Prometheus_Paperless-exporter = mkIf cfg.enableExporter {
      file = ../secrets/nixie/Monitoring/Exporters/${config.host.name}/Paperless.age;
      owner = "root";
    };

    services.nginx.virtualHosts."${config.host.networking.monitoringDomain}" = mkIf cfg.enableExporter (utils.makeNginxMetricConfig "paperless" (utils.makeNixContainerIP containerID) "TODO");
  };

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "paperless";
        containerPort = TODO;
        postgresqlName = "paperless";

        bindMounts = {
          "/var/lib/paperless/" = { hostPath = "${cfg.dataDir}/paperless"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${cfg.dataDir}/postgresql"; isReadOnly = false; };
          ${config.age.secrets.Paperless.path}.hostPath = config.age.secrets.Paperless.path;
          ${config.age.secrets.Prometheus_Paperless-exporter.path}.hostPath = config.age.secrets.Prometheus_Paperless-exporter.path;
        };

        cfg = {

        };
      }
    )
  ];
}
