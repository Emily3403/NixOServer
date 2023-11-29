{ ... }: {
  users.groups.restic.members = [ "restic" ];

  users.users = {
    restic = {
      isSystemUser = true;
      uid = 291;
      group = "restic";
    };
  };
}
