{ pkgs, config, lib, ...}: {

  services.nginx.virtualHosts = {
    "hedgedoc.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://192.168.7.104:3000/";
      serverAliases = [ "hackmd.${config.domainName}" ];
    };
  };

  containers.hedgedoc =
  let
    domainName = config.domainName;
    age = config.age;
  in
  {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.7.1";
    localAddress = "192.168.7.104";

    bindMounts = {
      "/var/lib/hedgedoc/" = {
        hostPath = "/data/HedgeDoc/hedgedoc";
        isReadOnly = false;
      };

      "/var/lib/postgresql" = {
        hostPath = "/data/HedgeDoc/postgresql";
        isReadOnly = false;
      };

      "/run/agenix/HedgeDocEnvironmentFile" = {
        hostPath = "/run/agenix/HedgeDocEnvironmentFile";
      };
    };

    config = { pkgs, config, lib, ...}: {
      system.stateVersion = "23.05";
      documentation.man.generateCaches = false;
      networking.firewall.allowedTCPPorts = [ 3000 ];

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

      services.hedgedoc = {
        enable = true;
        environmentFile = age.secrets.HedgeDocEnvironmentFile.path;

        settings = {
          domain = "hedgedoc.${domainName}";
          allowOrigin = [ "localhost" "hedgedoc.inet.tu-berlin.de" ];
          host = "0.0.0.0";
          protocolUseSSL = true;

          db = {
            dialect = "postgres";
            host = "/run/postgresql";
          };

          email = false;
          allowAnonymous = false;
          allowEmailRegister = false;
          allowFreeURL = true;
          requireFreeURLAuthentication = true;
          sessionSecret = "$SESSION_SECRET";

          oauth2 = {
            providerName = "Keycloak";
            clientID = "HedgeDoc";
            clientSecret = "$CLIENT_SECRET";

            authorizationURL = "https://keycloak.inet.tu-berlin.de/realms/INET/protocol/openid-connect/auth";
            tokenURL = "https://keycloak.inet.tu-berlin.de/realms/INET/protocol/openid-connect/token";
            baseURL = "https://keycloak.inet.tu-berlin.de";
            userProfileURL = "https://keycloak.inet.tu-berlin.de/realms/INET/protocol/openid-connect/userinfo";

            userProfileUsernameAttr = "name";
            userProfileDisplayNameAttr = "preferred_username";
            userProfileEmailAttr = "email";
            scope = "openid email profile";
            rolesClaim = "groups";
            accessRole = "";

          };


        };

      };

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_15;

        ensureDatabases = [ "hedgedoc" ];
        ensureUsers = [
          {
            name = "hedgedoc";
            ensurePermissions = { "DATABASE hedgedoc" = "ALL PRIVILEGES"; };
            ensureClauses = {
              superuser = true;  # TODO: This is bad practice but whatever because every container has a own postgres instance
            };
          }
        ];
      };

      users.users = {
        hedgedoc = {
          isSystemUser = true;
          uid = 5004;
          group = "hedgedoc";
        };

        postgres = {
          uid = 71;
        };
      };
    };
  };

  users.users = {
    hedgedoc = {
      isSystemUser = true;
      uid = 5004;
      group = "hedgedoc";
    };

    postgres = {
      uid = 71;
      group = "postgres";
    };
  };

  systemd.tmpfiles.rules = [
    "d /data/HedgeDoc/postgresql 0755 postgres"
    "d /data/HedgeDoc/hedgedoc 0755 hedgedoc"
  ];

}