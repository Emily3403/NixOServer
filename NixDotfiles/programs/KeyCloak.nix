let
  getThemePackage = pkgs: { name, url, rev, path }: pkgs.stdenv.mkDerivation rec {
    inherit name;

    src = fetchGit {
      inherit url rev;
    };

    installPhase = ''
      mkdir -p $out
      cp -r $src/${path}/* $out/
    '';
  };

in

{ pkgs, config, lib, ...}: {

  services.nginx.virtualHosts = {
    "keycloak.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      # According to https://www.keycloak.org/server/reverseproxy#_exposed_path_recommendations
      locations = {
        "~* ^/(admin|welcome|metrics|health)(/.*)?$".return = "403";
        "/" = {
          proxyPass = "http://192.168.7.101:80";
          extraConfig = ''
            proxy_busy_buffers_size   512k;
            proxy_buffers   4 512k;
            proxy_buffer_size   256k;
          '';
        };
      };
    };

    "keycloak-admin.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations = {
        "/.well-known" = {
          # Allow access to the .well-known path for ACME challenge validation
        };
        "/" = {
          proxyPass = "http://192.168.7.101:80";
          extraConfig = ''
          satisfy any;

          allow 192.168.16.0/24;
          allow 192.168.200.0/24;
          allow 192.168.201.0/24;
          allow 192.168.220.0/24;

          deny all;
          '';
        };
      };
    };
  };

  containers.keycloak =
  let
    domainName = config.domainName;
    age = config.age;
  in
  {

    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.7.1";
    localAddress = "192.168.7.101";

    bindMounts = {
      "/var/lib/postgresql" = {
        hostPath = "/data/keycloak/postgresql";
        isReadOnly = false;
      };

      "${age.secrets.KeyCloakDatabasePassword.path}" = { hostPath = age.secrets.KeyCloakDatabasePassword.path; };
    };

    config = { pkgs, config, lib, ...}: {
      system.stateVersion = "23.05";
      documentation.man.generateCaches = false;
      networking.firewall.allowedTCPPorts = [ 80 ];

      users.users.keycloak = {
        isNormalUser = true;
        uid = 62384;
      };

      programs = {
        neovim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
        };

        fish.enable = true;
      };
      users.users.root.shell = pkgs.fish;

      services.keycloak = {
        enable = true;

        settings = {
          hostname = "keycloak.${domainName}";
          hostname-admin = "keycloak-admin.${domainName}";

          hostname-strict-backchannel = true;
          proxy = "edge";
        };

        database.passwordFile = age.secrets.KeyCloakDatabasePassword.path;
        initialAdminPassword = "UwU";  # change on first login

        themes =  {
          keywind = (getThemePackage pkgs) {
            name = "keywind";
            url = "https://github.com/lukin/keywind";
            rev = "f7d5b2d753524802481e49e0e967af39a5088de0";
            path = "theme/keywind";
          };
        };
      };

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_15;
        settings.listen_addresses = lib.mkForce "*";

        ensureDatabases = [ "keycloak" ];
        ensureUsers = [
          {
            name = "keycloak";
            ensurePermissions = { "DATABASE keycloak" = "ALL PRIVILEGES"; };
            ensureClauses = {
              superuser = true;
            };
          }
        ];
      };

    };
  };

  users.users.keycloak = {
    isNormalUser = true;
    uid = 62384;
  };

  systemd.tmpfiles.rules = [
    "d /data/keycloak/postgresql 0755 postgres"
  ];

}