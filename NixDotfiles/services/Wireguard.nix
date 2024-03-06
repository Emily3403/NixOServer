{ pkgs, config, lib, ... }:
{
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = config.age.secrets.Wireguard.path;

    # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
    # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
    postSetup = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eno1 -j MASQUERADE
    '';

    # This undoes the above command
    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eno1 -j MASQUERADE
    '';

    peers = [
      {
        name = "emily";
        publicKey = "uhZWbo/z/3SO1K7L4gsut73eGVNovqZQbwhy+VMfOTs=";

        persistentKeepalive = 30;
        allowedIPs = [ "0.0.0.0/0" ];
      }
    ];
  };
}
