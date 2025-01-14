{ config, modulesPath, pkgs, lib, ... }: {
  host = {
    name = "nixie";
    id = "69420420";
    bootDevices = [ "wwn-0x600508b1001c45ba5b71f00bcbda09c6" "wwn-0x600508b1001c455e43aa950f99f84287" "wwn-0x600508b1001cd6bba7589bc2985434fa" "wwn-0x600508b1001c100c12a98dee2b4cec1f" ];
    #    additionalBootLoaderDevices = [ "usb-HP_iLO_Internal_SD-CARD_000002660A01-0:0" ];

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
      "tg3"
    ];

    kernelParams = [ "ip=130.149.220.19::130.149.220.126:255.255.255.128:nixie:enp7s0f0" ];
    networking.domainName = "ruwusch.de";
  };

  networking = {
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

        ipv6.addresses = [{
          address = "2001:638:809:ff1f:130:149:220:19";
          prefixLength = 64;
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
      internalInterfaces = [ "ve-+" ];
      externalInterface = "enp7s0f0";
    };
  };

  # import other host-specific things
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./services.nix
  ];
}
