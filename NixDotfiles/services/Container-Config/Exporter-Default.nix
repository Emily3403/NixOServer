{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.todo;
  utils = import ../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  cID = TODO;
in
{

  imports = [
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

        environment = {

        };
        environmentFiles = [ config.age.secrets.Prometheus_Todo-exporter.path ];
      }
    )
  ];
}
