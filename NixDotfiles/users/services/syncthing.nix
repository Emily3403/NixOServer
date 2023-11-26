{ ... }: {
  users.groups.syncthing.members = [ "syncthing" ];

  users.users = {
    syncthing = {
      isSystemUser = true;
      uid = 237;
      group = "syncthing";
    };
  };
}
