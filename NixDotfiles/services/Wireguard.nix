{ pkgs, config, lib, ... }:
{
  networking = {
    # Some networks don't allow the default wireguard port, so add two alternatives. 
    # Also, some networks block udp, so add a tcp alternative using tcp2udp (requires client setup).
    nat = {
      enable = true;
      internalInterfaces = [ "wg0" ];

      forwardPorts = [
        { sourcePort = 53; destination = "0.0.0.0:51820"; proto = "udp"; }
        { sourcePort = 124; destination = "0.0.0.0:51820"; proto = "udp"; }

        { sourcePort = 20; destination = "0.0.0.0:51820"; proto = "tcp"; }
        { sourcePort = 23; destination = "0.0.0.0:51820"; proto = "tcp"; }
      ];
    };

    firewall = {
      allowedTCPPorts = [ 20 23 51820 ];
      allowedUDPPorts = [ 53 124 51820 ];
    };

    wireguard.interfaces.wg0 = {
      ips = [ "192.168.42.0/24" ];
      listenPort = 51820;
      privateKeyFile = config.age.secrets.Wireguard.path;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 192.168.42.0/25 -o ${config.networking.nat.externalInterface} -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 192.168.42.0/25 -o ${config.networking.nat.externalInterface} -j MASQUERADE
      '';

      peers = [
        {
          name = "emily";
          publicKey = "uhZWbo/z/3SO1K7L4gsut73eGVNovqZQbwhy+VMfOTs=";

          persistentKeepalive = 30;
          allowedIPs = [ "192.168.42.1/32" ];
        }

        {
          name = "bernd";
          publicKey = "V2LyESuAgojOK8eOOj767Ybvei+WXvcpzVMk2shX0xc=";

          persistentKeepalive = 30;
          allowedIPs = [ "192.168.42.2/32" ];
        }

#        {
#          name = "carsten";
#          publicKey = "";
#
#          persistentKeepalive = 30;
#          allowedIPs = [ "192.168.42.113/32" ];
#        }
      ];
    };
  };
}


