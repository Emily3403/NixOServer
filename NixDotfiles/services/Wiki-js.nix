{ pkgs, config, lib, ...}: {

  services.nginx.virtualHosts = {
    "wiki.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://192.168.7.102:3000/";
    };
  };

  containers.wiki-js = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.7.1";
    localAddress = "192.168.7.102";

    bindMounts = {
      "/var/lib/wiki-js/" = {
        hostPath = "/data/wiki/wiki-js";
        isReadOnly = false;
      };

      "/var/lib/postgresql" = {
        hostPath = "/data/wiki/postgresql";
        isReadOnly = false;
      };

      "/run/agenix/SSHKey" = {
        hostPath = "/run/agenix/SSHKey";
      };
    };

    config = { pkgs, config, lib, ...}: {
      system.stateVersion = "23.05";
      documentation.man.generateCaches = false;
      networking.firewall.allowedTCPPorts = [ 3000 ];

      users.users = {
        wiki-js = {
          isNormalUser = true;
          uid = 5001;
        };

        postgres = {
          uid = 71;
        };
      };

      programs = {
        neovim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
        };

        fish.enable = true;
        git.enable = true;
      };
      users.users.root.shell = pkgs.fish;

      services.wiki-js = {
        enable = true;

        settings.db = {
          host = "/run/postgresql";
          user = "wiki-js";
        };
      };

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_15;

        ensureDatabases = [ "wiki" ];
        ensureUsers = [
          {
            name = "wiki-js";
            ensurePermissions = { "DATABASE wiki" = "ALL PRIVILEGES"; };
            ensureClauses = {
              superuser = true;  # TODO: This is bad practice but whatever because every container has a own postgres instance
            };
          }
        ];
      };
    };
  };

  users.users = {
    wiki-js = {
      isNormalUser = true;
      uid = 5001;
    };

    postgres = {
      uid = 71;
    };
  };

  systemd.tmpfiles.rules = [
    "d /data/wiki/postgresql 0755 postgres"
    "d /data/wiki/wiki-js 0755 wiki-js"
  ];

}