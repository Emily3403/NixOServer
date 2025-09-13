{ config, modulesPath, pkgs, lib, ... }: {
  host = {
    name = "nixie";
    id = "69420420";
    bootDevices = [ "wwn-0x600508b1001c45ba5b71f00bcbda09c6" "wwn-0x600508b1001c455e43aa950f99f84287" "wwn-0x600508b1001cd6bba7589bc2985434fa" "wwn-0x600508b1001c100c12a98dee2b4cec1f" ];
    #    additionalBootLoaderDevices = [ "usb-HP_iLO_Internal_SD-CARD_000002660A01-0:0" ];

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

    kernelParams = [ "ip=130.149.220.19::130.149.220.126:255.255.255.128:nixie:ens2f0" ];
    networking.domainName = "ruwusch.de";
  };

  networking = {
    useDHCP = false;

    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    timeServers = [ "0.nixos.pool.ntp.org" "1.nixos.pool.ntp.org" "2.nixos.pool.ntp.org" "3.nixos.pool.ntp.org" ];

    firewall.allowedTCPPorts = [ 22 80 443 ];
    firewall.allowedUDPPorts = [ ];

    defaultGateway = {
      interface = "ens2f0";
      address = "130.149.220.126";
    };

    defaultGateway6 = {
      interface = "ens2f0";
      address = "fe80::1";
    };

    interfaces = {
      ens2f0 = {
        ipv4.addresses = [{
          address = "130.149.220.19";
          prefixLength = 25;
        }];

        ipv6.addresses = [{
          address = "2001:638:809:ff1f:130:149:220:19";
          prefixLength = 64;
        }];
      };

      ens2f1 = {
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
      externalInterface = "ens2f0";
    };
  };

  zfs-root.boot.partitionScheme = {
    efiBoot = "-part1";
    bootPool = "-part2";
    rootPool = "-part3";
    swap = "-part4";
    biosBoot = "-part5";
  };

  # import other host-specific things
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./services.nix
  ];
}
