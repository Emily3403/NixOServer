{ ... }: {
  imports = [ ../postgres.nix ./prometheus.nix ];
  users.groups.grafana = {
    gid = 196;
    members = [ "grafana" ];
  };

  users.users = {
    grafana = {
      isSystemUser = true;
      uid = 196;
      group = "grafana";
      extraGroups = [ "prometheus" ];
    };
  };
}
