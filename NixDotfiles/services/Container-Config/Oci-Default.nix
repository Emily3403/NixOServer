{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.todo;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  cID = TODO;
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
      "d ${cfg.dataDir} 0750 TODO"
      "d ${cfg.dataDir}/todo 0750 TODO"
    ];

    age.secrets.Todo = {
      file = ../secrets/${config.host.name}/Todo.age;
      owner = "TODO";
    };

    age.secrets.Prometheus_Todo-exporter = mkIf cfg.enableExporter {
      file = ../secrets/nixie/Monitoring/Exporters/${config.host.name}/Todo.age;
      owner = "TODO";
    };

    services.nginx.virtualHosts."${config.host.networking.monitoringDomain}" = mkIf cfg.enableExporter (utils.makeNginxMetricConfig "todo" (utils.makeNixContainerIP cID) "TODO");
  };

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs cID;
        dataDir = cfg.dataDir;
        subdomain = cfg.subdomain;

        name = "todo";
        image = "TODO";
        containerPort = TODO;

        environmentFiles = [ config.age.secrets.Todo.path ];
        postgresEnvFile = config.age.secrets.Todo_Postgres.path;

        environment = {

        };

        volumes = [
          "${cfg.dataDir}/TODO:/TODO"
        ];
      }
    )

    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs cID;
        enable = cfg.enableExporter;
        dataDir = cfg.dataDir;
        fqdn = config.host.networking.monitoringDomain;

        name = "TODO";
        image = "TODO";

        containerPort = TODO;
        nginxLocation = "/todo-metrics";
        nginxProxyPassLocation = "/metrics";

        environmentFiles = [ config.age.secrets.Prometheus_Todo-exporter.path ];
        environment = {

        };
      }
    )
  ];
}
