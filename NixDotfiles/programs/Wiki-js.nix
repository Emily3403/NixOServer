{ pkgs, config, lib, ...}: {
  services.wiki-js = {
    enable = true;

    settings.db = {
      host = "localhost";
      user = "wiki";
      pass = "UwU";
    };
  };

  services.postgresql = {
    ensureDatabases = [ "wiki" ];
    ensureUsers = [
      {
        name = "wiki";
        ensurePermissions = { "DATABASE wiki" = "ALL PRIVILEGES"; };
      }
    ];
  };

  services.nginx.virtualHosts = {
    "new-wiki.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://localhost:3000/";
      serverAliases = [ "wiki.${config.domainName}" ];
    };
  };

  containers.wiki-js = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.7.1";
    localAddress = "192.168.7.101";

    config = { pkgs, config, lib, ...}: {
      system.stateVersion = "23.05";

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 80 ];
      };

      services.wiki-js = {
        enable = true;

        settings.port = 80;
        settings.db = {
          host = "localhost";
          user = "wiki";
          pass = "UwU";
        };
      };
    };
  };
}