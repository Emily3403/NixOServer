{ ... }: {
  imports = [ ./postgres.nix ];
  users.groups.nextcloud.members = [ "nextcloud" ];
  users.groups.video.members = [ "nextcloud" ];
  users.groups.render.members = [ "nextcloud" ];

  users.users = {
    nextcloud = {
      isSystemUser = true;
      uid = 5002;
      group = "nextcloud";
    };
  };
}
