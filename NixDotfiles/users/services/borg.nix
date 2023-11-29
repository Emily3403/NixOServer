{ ... }: {
  users.groups.borg.members = [ "borg" ];

  users.users = {
    borg = {
      isSystemUser = true;
      uid = 5006;
      group = "borg";
    };
  };
}
