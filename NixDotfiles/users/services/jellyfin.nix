{ ... }: {
  users.groups.jellyfin.members = [ "jellyfin" ];
  users.groups.video.members = [ "jellyfin" ];
  users.groups.render.members = [ "jellyfin" ];

  users.users = {
    jellyfin = {
      isSystemUser = true;
      uid = 5009;
      group = "jellyfin";
    };
  };
}
