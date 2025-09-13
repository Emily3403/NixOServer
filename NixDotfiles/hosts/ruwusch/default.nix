{ config, modulesPath, pkgs, lib, ... }: {
  host = {
    name = "ruwusch";
    id = "42042069";
    bootDevices = [ "wwn-0x5000cca257f559a4" "wwn-0x5000cca267f05a8f" "wwn-0x5000cca27dc00547" ];

    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAzQFMYrSvjGtzcOUbR1YHawaPMCBDnO4yRKsV7WHkg emily"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMooVZ98Wkne2js4jPgypBlPuxZGxJBu8QEhOdCkSTQj nana"
    ];

    zfs = {
      autoSnapshot = {
        enable = true;      # All values are chosen +1 to account for rounding issues
        quarterHourly = 9;  #  2h  of every 15min
        hourly = 49;        #  2d  of every 1h  (60m)
        daily = 15;         #  14d of every 1d  (24h)
        weekly = 9;         #  2m  of every 1w   (7d)
        monthly = 61;       #  5y  of every 1m  (30d)
      };

      arc = {
        minGB = 32;
        maxGB = 56;
      };

      encrypted = true;
    };

    initrdAdditionalKernelModules = [
      "uhci_hcd"
      "kvm-intel"
      "e1000e"
    ];
  };

  networking = {
    useDHCP = true;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    timeServers = [ "0.nixos.pool.ntp.org" "1.nixos.pool.ntp.org" "2.nixos.pool.ntp.org" "3.nixos.pool.ntp.org" ];

    firewall.allowedTCPPorts = [ 22 80 443 ];
    firewall.allowedUDPPorts = [ ];

    # For the nixos-containers
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "enp0s31f6";
    };

    # IPv6 Connectivity
    interfaces.enp0s31f6.ipv6.addresses = [{
        address = "2a01:4f8:10b:2f83::";
        prefixLength = 64;
    }];

    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp0s31f6";
    };
  };

  # This option is discouraged, however in all scenarios we want to import the root anymays as there is no other way of solving the problem
  boot.zfs.forceImportRoot = lib.mkForce true;

  # import other host-specific things
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./services.nix
  ];
}
