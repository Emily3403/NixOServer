{ pkgs, inputs, config, lib, ... }:
let
  wgcfg = config.host.services.wireguard;
  wscfg = config.host.services.wstunnel;
  fqdn = "${wscfg.subdomain}.${config.host.networking.domainName}";

  utils = import ../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  exporterContainerID = 23;

  mkPeerConfig = peer: ''
    [Peer]
    # friendly_name = ${peer.name}
    PublicKey = ${peer.publicKey}
    AllowedIPs = ${builtins.concatStringsSep " " peer.allowedIPs}
  '';

  # Generate the entire WireGuard config file
  wireguardConfig = builtins.concatStringsSep "\n" (map mkPeerConfig config.networking.wireguard.interfaces.wg0.peers);
in
{

  options.host.services = {
    wireguard = {
      port = mkOption {
        type = lib.types.port;
        default = 51820;
      };

      enableExporter = mkOption {
        type = types.bool;
        default = true;
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
    age.secrets.WireGuard = {
      file = ../secrets/${config.host.name}/WireGuard.age;
      owner = "root";
    };

    networking = {
      nat = {
        enable = true;
        enableIPv6 = true;
        internalInterfaces = [ "wg0" ];
      };

      firewall = {
        allowedTCPPorts = [ 20 23 ];
        allowedUDPPorts = [ 53 124 51820 ];
      };

      wireguard.interfaces.wg0 = let
        ip-range = "192.168.42.0/24";
        ip6-range = "fd42:42:42::0/64";
      in {
        ips = [ "${ip-range}" "${ip6-range}"  ];
        listenPort = 51820;
        privateKeyFile = config.age.secrets.WireGuard.path;

        postSetup = ''
          ${pkgs.iptables}/bin/iptables  -t nat -A POSTROUTING -s ${ip-range}  -o ${config.networking.nat.externalInterface} -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s ${ip6-range} -o ${config.networking.nat.externalInterface} -j MASQUERADE
        '';

        postShutdown = ''
          ${pkgs.iptables}/bin/iptables  -t nat -D POSTROUTING -s ${ip-range}  -o ${config.networking.nat.externalInterface} -j MASQUERADE
          ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s ${ip6-range} -o ${config.networking.nat.externalInterface} -j MASQUERADE

        '';

        peers = [
          {
            name = "Emily";
            publicKey = "uhZWbo/z/3SO1K7L4gsut73eGVNovqZQbwhy+VMfOTs=";

            persistentKeepalive = 30;
            allowedIPs = [ "192.168.42.1/32" "fd42:42:42::1/128" ];
          }

          {
            name = "Bernd";
            publicKey = "V2LyESuAgojOK8eOOj767Ybvei+WXvcpzVMk2shX0xc=";

            persistentKeepalive = 30;
            allowedIPs = [ "192.168.42.2/32" ];
          }

          {
            name = "Carsten";
            publicKey = "kt6AWgqmTljmCUYj7vno3GuBLDVTxTNldcb4fAtjdmI=";

            persistentKeepalive = 30;
            allowedIPs = [ "192.168.42.77/32" ];
          }
        ];
      };
    };

    environment.etc."wireguard.conf".text = wireguardConfig;
    services.nginx.virtualHosts."${config.host.networking.monitoringDomain}" = mkIf wgcfg.enableExporter (utils.makeNginxMetricConfig "wireguard" "127.0.0.1" "9586");


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

  imports = [(
    import ./Container-Config/Oci-Container.nix {
      inherit config lib pkgs;
      enable = wgcfg.enableExporter;
      subdomain = "${config.host.name}.status";
      dataDir = wgcfg.dataDir;
      createPod = false;

      name = "wireguard-exporter";
      image = "mindflavor/prometheus-wireguard-exporter:3.6.6";
      containerID = exporterContainerID;

      makeNginxConfig = false;
      containerPort = 9586;

      additionalContainerConfig = {
        extraOptions = [ "--cap-add=NET_ADMIN" "--net=host" ];
        cmd = [ "-a" "false" ];
      };

      environment = {
        PROMETHEUS_WIREGUARD_EXPORTER_ADDRESS = "127.0.0.1";
        PROMETHEUS_WIREGUARD_EXPORTER_CONFIG_FILE_NAMES = "/etc/wireguard.conf";
        PROMETHEUS_WIREGUARD_EXPORTER_EXPORT_REMOTE_IP_AND_PORT_ENABLED = "true";
      };

      volumes = [ "/etc/wireguard.conf:/etc/wireguard.conf:ro" ];
    }
  )];
}
