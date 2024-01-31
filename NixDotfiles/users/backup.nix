{ pkgs, config, lib, ... }: {
  users.users.emily = {
    isNormalUser = true;
    home = "/home/backup";
    description = "Backup";

    shell = pkgs.fish;
    createHome = true;
    uid = 1044;
    extraGroups = [ ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAzQFMYrSvjGtzcOUbR1YHawaPMCBDnO4yRKsV7WHkg emily"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINA0V/ByFxlMU8nBJ+R2RGxr0uZAapovARLPbHYmNE2V emily"
    ];

  };
}
