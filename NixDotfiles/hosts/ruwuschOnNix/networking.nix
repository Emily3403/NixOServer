{ pkgs, config, lib, ...}: {
  domainName = "ruwusch.de";
  containerHostIP = "192.168.7.1";

  networking = {
    useDHCP = true;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall.allowedTCPPorts = [ 22 80 443 ];

    # For the nixos-containers
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "enp0s31f6";
    };
  };
}
