{ pkgs, config, lib, ... }:
let
  wgcfg = config.host.services.wireguard;
  wscfg = config.host.services.wstunnel;
  fqdn = "${wscfg.subdomain}.${config.host.networking.domainName}";
  inherit (lib) mkIf mkOption types;
in
{

  options.host.services = {
    wireguard = {
      port = mkOption {
        type = lib.types.port;
        default = 51820;
      };
    };

    wstunnel = {
      subdomain = mkOption {
        type = types.str;
        default = "vpn";
      };

      port = mkOption {
        type = lib.types.port;
        default = 51820;
      };
    };
  };




  config = {
    age.secrets.Wireguard = {
      file = ../secrets/${config.host.name}/Wireguard.age;
      owner = "root";
    };

    networking = {
      nat = {
        enable = true;
        internalInterfaces = [ "wg0" ];
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
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 192.168.42.0/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
        '';

        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 192.168.42.0/24 -o ${config.networking.nat.externalInterface} -j MASQUERADE
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

          {
            name = "carsten";
            publicKey = "kt6AWgqmTljmCUYj7vno3GuBLDVTxTNldcb4fAtjdmI=";

            persistentKeepalive = 30;
            allowedIPs = [ "192.168.42.77/32" ];
          }
        ];
      };
    };

    services.nginx.logError = "stderr debug";

    services.nginx.virtualHosts."${fqdn}" = {
      forceSSL = true;
      enableACME = true;

      http2 = false;
      http3 = false;

      locations."/wstunnel" = {
        proxyPass = "https://127.0.0.1:${toString wscfg.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_connect_timeout       5m;
          proxy_send_timeout          5m;
          proxy_read_timeout          5m;
          send_timeout                5m;
        '';
      };
    };

    # Some networks don't allow the default wireguard port or udp traffic, so add the wstunnel alternative
    services.wstunnel = {
      enable = true;
      servers."${config.host.name}" = {
        useACMEHost = fqdn;
        websocketPingInterval = 30;

        listen = {
          port = wscfg.port;
          host = "0.0.0.0";
        };

        restrictTo = [{
          host = "127.0.0.1";
          port = wgcfg.port;
        }];
      };
    };
  };


}
