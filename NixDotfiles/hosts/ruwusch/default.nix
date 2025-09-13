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
        enable = true;
        daily = 15;
        weekly = 9;
        monthly = 60; # 5 years
      };

      arc = {
        minGB = 78;
        maxGB = 112;
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
