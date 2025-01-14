# Services that should exist:
# - Jellyfin
# - Transmission-openvpn (docker)  (4TB – 8TB)
# - openvpn compatible vpn
#    - Bonus: Able to use mulvad
# - Some form of cloud, probably Nextcloud  (4TB)
#   - WebDAV, different Users, Calendar, Version control
#   - Client _has_ to be able to check for metered connection
#   - Stores the data encrypted
# - Central identity management with Keycloak
# - isisdl compressed videos    (2TB)


{ config, modulesPath, pkgs, lib, ... }: {
  host = {
    name = "ruwusch";
    id = "42069420";
    bootDevices = [ "wwn-0x5000c500db1e5ef4" "wwn-0x5000c500db3750a7" ];
#    bootDevices = [ "wwn-0x5000c500db24ffb3" "wwn-0x5000c500db235066" ];

    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAzQFMYrSvjGtzcOUbR1YHawaPMCBDnO4yRKsV7WHkg emily"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMooVZ98Wkne2js4jPgypBlPuxZGxJBu8QEhOdCkSTQj"
    ];

    zfs = {
      autoSnapshot = {
        enable = true;
        daily = 15;
        weekly = 9;
        monthly = 60;  # 5 years
      };

      arc = {
        minGB = 32;
        maxGB = 56;
      };

      encrypted = true;
    };

    initrdAdditionalKernelModules = [
      "uhci_hcd"
      "kvm-amd"
      "e1000e"
    ];

    networking.domainName = "ruwusch.de";
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
  };

  # This option is discouraged, however in all scenarios we want to import the root anymays as there is no other way of solving the problem
  boot.zfs.forceImportRoot = lib.mkForce true;
  powerManagement.cpuFreqGovernor = "performance";

  # import other host-specific things
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./services.nix
  ];
}
