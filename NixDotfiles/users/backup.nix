{ pkgs, config, lib, ... }: {
  users.users.backup = {
    isNormalUser = true;
    home = "/home/backup";
    description = "BackupPC Service Account";

    shell = pkgs.fish;
    createHome = true;
    uid = 1100;
    group = "backup";
    extraGroups = [ ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAzQFMYrSvjGtzcOUbR1YHawaPMCBDnO4yRKsV7WHkg emily"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOSNZTlWLtNGGfQMmiCtO31naX6jMHsGj3B8LnxfgUvo backuppc@UwUGrave"
    ];
  };

  users.groups.backup = {
    name = "backup";
    gid = 1100;
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
