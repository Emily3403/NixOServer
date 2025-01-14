{ pkgs, config, lib, ... }: {
  users.users.data-backup = {
    isNormalUser = true;
    home = "/home/data-backup";
    description = "Emily's ✨ Data Backups";

    shell = pkgs.fish;
    createHome = true;
    uid = 1102;
    group = "data-backup";
    extraGroups = [ ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAzQFMYrSvjGtzcOUbR1YHawaPMCBDnO4yRKsV7WHkg emily"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOSNZTlWLtNGGfQMmiCtO31naX6jMHsGj3B8LnxfgUvo backup@UwUGrave"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF0BUkvDDSSS0AQB4wTdwcCSE4tBrtiaTJv7EUxvlJgD backup@data-vault"
    ];
  };

  users.groups.data-backup = {
    name = "data-backup";
    gid = 1102;
    members = [ "data-backup" ];
  };
}
