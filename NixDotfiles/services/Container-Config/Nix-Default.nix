{ pkgs, config, lib, ... }:
let

  cfg = config.host.services.todo;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = TODO;
in
{
  options.host.services.todo = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Todo";
    };

    subdomain = mkOption {
      type = types.str;
      default = "todo";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 todo"
      "d ${cfg.dataDir}/todo 0750 todo"
      "d ${cfg.dataDir}/postgresql 0750 postgres"
    ];

    age.secrets.Todo = {
      file = ../secrets/${config.host.name}/Todo.age;
      owner = "todo";
    };

    age.secrets.Prometheus_Todo-exporter = mkIf cfg.enableExporter {
      file = ../secrets/nixie/Monitoring/Exporters/${config.host.name}/Todo.age;
      owner = "root";
    };

    services.nginx.virtualHosts."${config.host.networking.monitoringDomain}" = mkIf cfg.enableExporter (utils.makeNginxMetricConfig "todo" (utils.makeNixContainerIP containerID) "TODO");
  };

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "todo";
        containerPort = TODO;
        postgresqlName = "todo";

        bindMounts = {
          "/var/lib/todo/" = { hostPath = "${cfg.dataDir}/todo"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${cfg.dataDir}/postgresql"; isReadOnly = false; };
          ${config.age.secrets.Todo.path}.hostPath = config.age.secrets.Todo.path;
          ${config.age.secrets.Prometheus_Todo-exporter.path}.hostPath = config.age.secrets.Prometheus_Todo-exporter.path;
        };

        cfg = {

        };
      }
    )
  ];
}
