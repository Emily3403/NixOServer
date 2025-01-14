{ pkgs, config, lib, ... }: {
  users.users.backup = {
    isNormalUser = true;
    home = "/home/backup";
    description = "Backup";

    shell = pkgs.fish;
    createHome = true;
    uid = 1044;
    group = "backup";
    extraGroups = [ ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAzQFMYrSvjGtzcOUbR1YHawaPMCBDnO4yRKsV7WHkg emily"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOSNZTlWLtNGGfQMmiCtO31naX6jMHsGj3B8LnxfgUvo backup@UwUGrave"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF0BUkvDDSSS0AQB4wTdwcCSE4tBrtiaTJv7EUxvlJgD backup@data-vault"
    ];
  };

  users.groups.backup = {
    name = "backup";
    members = [ "backup" ];
  };

  # Enable rsync to read everything
  security.wrappers = {
    "rsync" = {
      owner = "backup";
      group = "backup";
      capabilities = "cap_dac_read_search+ep";
      source = "${pkgs.rsync.out}/bin/rsync";
    };
  };
}
