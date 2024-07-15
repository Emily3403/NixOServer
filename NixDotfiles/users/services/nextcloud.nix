{ ... }: {
  imports = [ ./postgres.nix ];
  users.groups.nextcloud.members = [ "nextcloud" ];
  users.groups.nextcloud-exporter.members = [ "nextcloud-exporter" ];

  users.groups.video.members = [ "nextcloud" ];
  users.groups.render.members = [ "nextcloud" ];

  users.users = {
    nextcloud = {
      isSystemUser = true;
      uid = 5002;
      group = "nextcloud";
    };

    nextcloud-exporter = {
      isSystemUser = true;
      uid = 5102;
      group = "nextcloud-exporter";
    };
  };
}
