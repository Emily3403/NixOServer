{ pkgs, config, lib, ...}: {
  domainName = "ruwusch.de";

  networking = {
    useDHCP = true;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };

    # For the containers
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "enp0s31f6";
    };

  };
}