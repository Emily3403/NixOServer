{ pkgs, inputs, config, lib, ... }:
let
  cfg = config.host.services.todo;
  utils = import ../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = TODO;
in
{

  imports = [
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
