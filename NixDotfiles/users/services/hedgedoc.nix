{ ... }: {
  imports = [ ./postgres.nix ];
  users.groups.hedgedoc.members = [ "hedgedoc" ];

  users.users = {
    hedgedoc = {
      isSystemUser = true;
      uid = 5004;
      group = "hedgedoc";
    };
  };
}
