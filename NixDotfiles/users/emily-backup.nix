{ pkgs, inputs, config, lib, ... }: {
  users.users.emily-backup = {
    isNormalUser = true;
    home = "/home/emily-backup";
    description = "Emily's ✨ User Backups";

    shell = pkgs.fish;
    createHome = true;
    uid = 1101;
    group = "emily-backup";
    extraGroups = [ ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINA0V/ByFxlMU8nBJ+R2RGxr0uZAapovARLPbHYmNE2V user@emily"
    ];
  };

  users.groups.emily-backup = {
    name = "emily-backup";
    gid = 1101;
    members = [ "emily-backup" ];
  };
}
