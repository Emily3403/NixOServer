{ pkgs, config, lib, ...}: {
  domainName = "inet.tu-berlin.de";

  networking = {
    useDHCP = false;

    nameservers = [ "130.149.220.253" "130.149.152.187" ];
    search = [ "inet.tu-berlin.de" "net.t-labs.tu-berlin.de" ];

    defaultGateway = {
      address = "130.149.220.126";
      interface = "enX0";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enX0";
    };

    interfaces.enX0 = {
      ipv4.addresses = [{
        address = "130.149.220.7";
        prefixLength = 25;
      }];
    };

    interfaces.enX1 = {
      ipv4.addresses = [{
        address = "192.168.200.7";
        prefixLength = 25;
      }];
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 443 ];
    };
  };
}