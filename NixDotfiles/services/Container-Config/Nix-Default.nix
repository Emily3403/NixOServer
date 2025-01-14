{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.TODO;
  inherit (lib) mkIf mkOption types;
in
{
  options.host.services.TODO = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/TODO";
    };

    subdomain = mkOption {
      type = types.str;
      default = "TODO";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 TODO"
      "d ${cfg.dataDir}/TODO 0750 TODO"
      "d ${cfg.dataDir}/postgresql 0750 postgres"
    ];

    age.secrets.TODO = {
      file = ../secrets/${config.host.name}/TODO.age;
      owner = "TODO";
    };

    age.secrets = mkIf cfg.enableExporter {
      Prometheus_TODO-exporter-environment = {
        file = ../secrets/nixie/Monitoring/Exporters/TODO-Exporter.age;
        owner = "root";
      };
    };
  };

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;

        name = "TODO";
        subdomain = cfg.subdomain;
        containerID = TODO;
        containerPort = 80;
        postgresqlName = "TODO";

        bindMounts = {
          "/var/lib/TODO/" = { hostPath = "${cfg.dataDir}/TODO"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${cfg.dataDir}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.TODO.path}".hostPath = config.age.secrets.TODO.path;
        };

        cfg = { };
      }
    )
  ];
}
