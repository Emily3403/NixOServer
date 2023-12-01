{ ... }: {
  users.groups.jellyfin.members = [ "jellyfin" ];

  users.users = {
    jellyfin = {
      isSystemUser = true;
      uid = 5009;
      group = "jellyfin";
    };
  };
}
