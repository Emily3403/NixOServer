{ config, modulesPath, pkgs, lib, ... }: {
  host = {
    name = "ruwusch";
    id = "42042069";
    bootDevices = [ "wwn-0x5000cca267f080f2" "wwn-0x5000cca267ebaefd" "wwn-0x5000cca252d156af" ];

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
      externalInterface = "eno1";
    };

    # IPv6 Connectivity
    interfaces.eno1.ipv6.addresses = [{
        address = "2a01:4f8:172:3d0d::";
        prefixLength = 64;
    }];

    defaultGateway6 = {
      address = "fe80::1";
      interface = "eno1";
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
