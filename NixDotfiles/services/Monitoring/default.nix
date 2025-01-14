{ config, lib, pkgs, ... }: {
  imports = [ ./Grafana.nix ./Prometheus.nix ];

  # Shared for Grafana and Prometheus
  config.age.secrets.Prometheus_nixie-pw = {
    file = ../../secrets/${config.host.name}/Monitoring/Access/nixie.age;
    owner = "prometheus";
    group = "grafana";
    mode = "440";
  };
}
