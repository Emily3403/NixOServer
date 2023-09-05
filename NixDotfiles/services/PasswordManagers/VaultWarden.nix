{ pkgs, config, lib, ...}: {

  services.nginx.virtualHosts = {
    "vaultwarden.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://192.168.7.140:8000/";
    };
  };

  containers.vaultwarden =
  let
    domainName = config.domainName;
    age = config.age;
  in
  {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.7.1";
    localAddress = "192.168.7.140";

    bindMounts = {
      "/var/lib/bitwarden_rs/" = {
        hostPath = "/data/VaultWarden/bitwarden_rs";
        isReadOnly = false;
      };

      "/var/lib/postgresql" = {
        hostPath = "/data/VaultWarden/postgresql";
        isReadOnly = false;
      };

      "/run/agenix/VaultWardenEnvironmentFile" = {
        hostPath = "/run/agenix/VaultWardenEnvironmentFile";
      };
    };

    config = { pkgs, config, lib, ...}: {
      system.stateVersion = "23.05";
      documentation.man.generateCaches = false;
      networking.firewall.allowedTCPPorts = [ 8000 ];

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

      services.vaultwarden = {
        enable = true;
        environmentFile = age.secrets.VaultWardenEnvironmentFile.path;
        dbBackend = "postgresql";

        config = {
          DATABASE_URL = "postgres://vaultwarden@%2Frun%2Fpostgresql/vaultwarden";
          DOMAIN = "https://vaultwarden.${domainName}";
          ROCKET_ADDRESS="0.0.0.0";

          SIGNUPS_ALLOWED = false;
          SIGNUPS_VERIFY = true;
          DISABLE_2FA_REMEMBER = true;
          ORG_EVENTS_ENABLED = true;
          EVENTS_DAYS_RETAIN = 30;
          TRASH_AUTO_DELETE_DAYS = 30;

          SMTP_HOST = "smtp.gmail.com";
          SMTP_FROM = "nixie3403@gmail.com";
          SMTP_FROM_NAME = "VaultWarden";
          SMTP_SECURITY = "force_tls";
          SMTP_PORT = "465";
          SMTP_USERNAME = "nixie3403@gmail.com";

        };

      };

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_15;

        ensureDatabases = [ "vaultwarden" ];
        ensureUsers = [
          {
            name = "vaultwarden";
            ensurePermissions = { "DATABASE vaultwarden" = "ALL PRIVILEGES"; };
            ensureClauses = {
              superuser = true;  # TODO: This is bad practice but whatever because every container has a own postgres instance
            };
          }
        ];
      };

      users.users = {
        vaultwarden = {
          isSystemUser = true;
          uid = 5040;
          group = "vaultwarden";
        };

        postgres = {
          uid = 71;
        };
      };
    };
  };

  users.users = {
    vaultwarden = {
      isSystemUser = true;
      uid = 5040;
      group = "vaultwarden";
    };

    postgres = {
      uid = 71;
    };
  };

  systemd.tmpfiles.rules = [
    "d /data/VaultWarden/postgresql 0755 postgres"
    "d /data/VaultWarden/bitwarden_rs 0755 vaultwarden"
  ];

}