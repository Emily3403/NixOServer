{ pkgs, config, lib, ... }:
{
  networking = {
    wireguard.interfaces.wg0 = {
      ips = [ "192.168.42.0/25" ];
      listenPort = 51820;
      privateKeyFile = config.age.secrets.Wireguard.path;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 192.168.42.0/25 -o eno1 -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 192.168.42.0/25 -o eno1 -j MASQUERADE
      '';

      peers = [
        {
          name = "emily";
          publicKey = "uhZWbo/z/3SO1K7L4gsut73eGVNovqZQbwhy+VMfOTs=";

          persistentKeepalive = 30;
          allowedIPs = [ "192.168.42.1/32" ];
        }
      ];
    };
  };
}


