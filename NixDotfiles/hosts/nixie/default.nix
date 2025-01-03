{ config, modulesPath, pkgs, pkgs-unfree, lib, ... }: {
  host = {
    name = "nixie";
    id = "abcd1234";
    bootDevices = [ "bootDevices_placeholder" ];

    enableHardwareAcceleration = true;

    zfs = {
      autoSnapshot = {
        enable = true;
        daily = 15;
        weekly = 9;
        monthly = 60;  # 5 years
      };

      arc = {
        minGB = 64;
        maxGB = 96;
      };

      encrypted = true;
    };

    additionalKernelModules = [
      "uhci_hcd"
      "kvm-intel"
    ];

    networking.domainName = "ruwusch.de";
  };

  networking = {
    hostName = "nixie";
    hostId = "abcd1234";  # TODO: Set this manually
    useDHCP = false;

    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    timeServers = [ "0.nixos.pool.ntp.org" "1.nixos.pool.ntp.org" "2.nixos.pool.ntp.org" "3.nixos.pool.ntp.org" ];

    firewall.allowedTCPPorts = [ 22 80 443 ];
    firewall.allowedUDPPorts = [ ];

    defaultGateway = {
      interface = "enp7s0f0";
      address = "130.149.220.126";
    };

    defaultGateway6 = {
      interface = "enp7s0f0";
      address = "fe80::1";
    };

    interfaces = {
      enp7s0f0 = {
        ipv4.addresses = [{
          address = "130.149.220.19";
          prefixLength = 25;
        }];
      };

      enp7s0f1 = {
        ipv4.addresses = [{
          address = "192.168.200.19";
          prefixLength = 25;
        }];
      };
    };

    # For the nixos-containers and wireguard
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" "wg0" ];
      externalInterface = "enp7s0f0";
    };
  };

  # import other host-specific things
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./services.nix
  ];
}
