{ config, modulesPath, pkgs, lib, ... }: {
  host = {
    name = "old-ruwusch";
    id = "74d69d3c";
    bootDevices = [ "ata-HGST_HUH721008ALE600_JEKEPRYZ" "ata-HGST_HUH721008ALE600_7SH74DYD" "ata-HGST_HUH721008ALE600_JEK330VN" ];

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
        minGB = 64;
        maxGB = 96;
      };

      encrypted = true;
    };

    initrdAdditionalKernelModules = [
      "uhci_hcd"
      "kvm-intel"
      "e1000e"
    ];
  };

  zfs-root.fileSystems.datasets = lib.mkForce {
    "bpool/nixos/root" = "/boot";
    "rpool/nixos/root" = "/";
    "rpool/nixos/home" = "/home";
    "rpool/nixos/var/lib" = "/var/lib";
    "rpool/nixos/var/log" = "/var/log";
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
