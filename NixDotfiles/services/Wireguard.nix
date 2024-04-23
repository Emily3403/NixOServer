{ pkgs, config, lib, ... }:
{
  networking = {
    wireguard.interfaces.wg0 = {
      ips = [ "192.168.42.0/25" ];
      listenPort = 51820;
      privateKeyFile = config.age.secrets.Wireguard.path;

      peers = [
        {
          name = "emily";
          publicKey = "uhZWbo/z/3SO1K7L4gsut73eGVNovqZQbwhy+VMfOTs=";

          persistentKeepalive = 30;
          allowedIPs = [ "192.168.42.1/32" ];
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


