{ pkgs, config, lib, ... }: {
  domainName = "ruwusch.de";
  containerHostIP = "192.168.7.1";

  networking = {
    hostName = "nixie";
    hostId = "abcd1234";
    useDHCP = false;

    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    timeServers = [ "0.nixos.pool.ntp.org" "1.nixos.pool.ntp.org" "2.nixos.pool.ntp.org" "3.nixos.pool.ntp.org" ];

    firewall.allowedTCPPorts = [ 22 80 443 22000 ];
    firewall.allowedUDPPorts = [ 21027 22000 ];

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

    # For the nixos-containers
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" "wg0" ];
      externalInterface = "enp7s0f0";
    };
  };
}
