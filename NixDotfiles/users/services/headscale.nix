{ ... }: {
  imports = [ ./postgres.nix ];
  users.groups.headscale.members = [ "headscale" ];

  users.users = {
    headscale = {
      isSystemUser = true;
      uid = 5010;
      group = "headscale";
    };
  };
}
