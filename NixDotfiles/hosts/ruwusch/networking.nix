{ pkgs, config, lib, ... }: {
  domainName = "ruwusch.de";
  containerHostIP = "192.168.7.1";

  networking = {
    useDHCP = true;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall.allowedTCPPorts = [ 22 80 443 ];
    firewall.allowedUDPPorts = [ ];

    # For the nixos-containers
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" "wg0" ];
      externalInterface = "eno1";
    };
  };
}
