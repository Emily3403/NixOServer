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
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs containerID;
        dataDir = cfg.dataDir;
        subdomain = cfg.subdomain;

        name = "todo";
        image = "TODO";

        containerPort = TODO;
        environment = {

        };
        environmentFiles = [ config.age.secrets.TODO.path ];

        volumes = [
          "${cfg.dataDir}/TODO:/TODO"
        ];
      }
    )

    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        enable = cfg.enableExporter;
        dataDir = cfg.dataDir;
        fqdn = config.host.networking.monitoringDomain;

        name = "TODO";
        image = "TODO";
        containerID = TODO;

        containerPort = TODO;
        nginxLocation = "/todo-metrics";
        nginxProxyPassLocation = "/metrics";

        environment = {

        };
        environmentFiles = [ config.age.secrets.Prometheus_Todo-exporter.path ];
      }
    )
  ];
}
