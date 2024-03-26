{ ... }: {
  imports = [ ./mysql.nix ];
  users.groups.photoprism.members = [ "photoprism" ];

  users.users = {
    photoprism = {
      isNormalUser = true;
      uid = 5011;
      group = "photoprism";
    };
  };
}
