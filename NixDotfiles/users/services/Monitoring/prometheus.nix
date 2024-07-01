{ ... }: {
  users.groups.prometheus = {
    gid = 255;
    members = [ "prometheus" "grafana" ];
  };

  users.users = {
    prometheus = {
      isSystemUser = true;
      uid = 255;
      group = "prometheus";
    };
  };
}
