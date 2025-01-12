{ config, modulesPath, pkgs, lib, ... }: {
  host = {
    name = "nixie";
    id = "abcd1234";
    bootDevices = [ "wwn-0x600508b1001c5029b5a15539c6e5c036" "wwn-0x600508b1001cbe28f550555fc3bd3cbe" "wwn-0x600508b1001c6475f8f96e4aaf5cfa76" "wwn-0x600508b1001c9652ea88895b0976fc23" ];
#    additionalBootLoaderDevices = [ "usb-HP_iLO_Internal_SD-CARD_000002660A01-0:0" ];

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
