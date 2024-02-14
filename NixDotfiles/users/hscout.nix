{ pkgs, config, lib, ... }: {
  users.users.hscout = {
    isNormalUser = true;
    home = "/home/hscout";
    description = "Hetzner Server Scouter";
    linger = true;

    shell = pkgs.fish;
    createHome = true;
    uid = 1045;
    extraGroups = [ ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAzQFMYrSvjGtzcOUbR1YHawaPMCBDnO4yRKsV7WHkg emily"
    ];

  };
}
