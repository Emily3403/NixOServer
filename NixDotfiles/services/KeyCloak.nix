let

  SUBDOMAIN = "keycloak";
  SUBDOMAIN_ADMIN = "keycloak-admin";
  CONTAINER_IP = "192.168.7.101";
  CONTAINER_PORT = 80;
  DATA_DIR = "/data/Keycloak";

in

{ pkgs, config, lib, ...}: {

  imports = [ ../users/services/keycloak.nix ];

  services.nginx.virtualHosts = {
    "${SUBDOMAIN}.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      # According to https://www.keycloak.org/server/reverseproxy#_exposed_path_recommendations
      locations = {
        "~* ^/(admin|welcome|metrics|health)(/.*)?$".return = "403";
        "/" = {
          proxyPass = "http://${CONTAINER_IP}:${toString CONTAINER_PORT}";
          extraConfig = ''
            proxy_busy_buffers_size   512k;
            proxy_buffers   4 512k;
            proxy_buffer_size   256k;
          '';
        };
      };
    };

    "${SUBDOMAIN_ADMIN}.${config.domainName}" = {
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
            allow ::1;
            allow 127.0.0.1;
          deny all;
          '';
        };
      };
    };
  };

  containers.keycloak = let cfg = config; in {

    autoStart = true;
    privateNetwork = true;
    hostAddress = config.containerHostIP;
    localAddress = "${CONTAINER_IP}";

    bindMounts = {
      "/var/lib/postgresql" = { hostPath = "${DATA_DIR}/postgresql"; isReadOnly = false; };
      "${cfg.age.secrets.KeyCloak_DatabasePassword.path}" = { hostPath = cfg.age.secrets.KeyCloak_DatabasePassword.path; };
    };

    config = { pkgs, config, lib, ...}: {
      networking.firewall.enable = false;
      imports = [
        ../users/root.nix
        ../users/services/keycloak.nix
        ../system.nix
      ];

      services.keycloak = {
        enable = true;

        settings = {
          hostname = "${SUBDOMAIN}.${cfg.domainName}";
          hostname-admin = "${SUBDOMAIN_ADMIN}.${cfg.domainName}";

          hostname-strict-backchannel = true;
          proxy = "edge";
        };

        database.passwordFile = cfg.age.secrets.KeyCloak_DatabasePassword.path;
        initialAdminPassword = "changeme";  # TODO: Change this

        themes.keywind = pkgs.stdenv.mkDerivation rec {
          name = "keywind";
          src = fetchGit {
            url = "https://github.com/lukin/keywind";
            rev = "6e5ef061bfdaafd7d22a3c812104ffe42aaa55b8";
          };
          installPhase = ''
            mkdir -p $out
            cp -r $src/theme/keywind/* $out/
          '';
        };
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/postgresql 0755 postgres"
  ];

}