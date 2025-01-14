{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.keycloak;
  inherit (lib) mkIf mkOption types;
  format = pkgs.formats.json { };
in
{
  options.host.services.keycloak = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Keycloak";
    };

    subdomain = mkOption {
      type = types.str;
      default = "auth";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };

    domain = mkOption {
      type = types.str;
      default = config.host.networking.domainName;
      description = "The domain name for the Keycloak instance, used by other services";
    };

    name = mkOption {
      type = types.str;
      default = "Keycloak";
    };

    realm = mkOption {
      type = types.str;
      default = "master";
    };

    attributeMapper =
    let
      options = {

        username = mkOption {
          type = types.str;
          default = "preferred_username";
          description = "The attribute for the username.";
        };

        name = mkOption {
          type = types.str;
          default = "name";
        };

        email = mkOption {
          type = types.str;
          default = "email";
        };

        groups = mkOption {
          type = types.str;
          default = "groups";
        };

      };
    in
      mkOption
      {
          type = types.submodule {
            freeformType = format.type;
            inherit options;
          };
          default = { };
      };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 keycloak"
      "d ${cfg.dataDir}/postgresql 0750 postgres"
    ];

    age.secrets.Keycloak = {
      file = ../secrets/${config.host.name}/Keycloak.age;
      owner = "keycloak";
    };
  };

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;

        name = "keycloak";
        subdomain = cfg.subdomain;
        containerID = 2;

        containerPort = 80;

        bindMounts = {
          "/var/lib/postgresql" = { hostPath = "${cfg.dataDir}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.Keycloak.path}".hostPath = config.age.secrets.Keycloak.path;
        };

        additionalNginxConfig.locations = {
          "~* ^/(admin|welcome|metrics|health)(/.*)?$".return = "403";
        };
        additionalNginxLocationConfig.extraConfig = ''
          proxy_busy_buffers_size   512k;
          proxy_buffers           4 512k;
          proxy_buffer_size         256k;
        '';

        additionalNginxHostConfig."${config.host.services.keycloak.subdomain}-admin.${config.host.networking.domainName}" = {
          forceSSL = true;
          enableACME = true;

          locations = {
            "/.well-known" = {
              # Allow access to the .well-known path for ACME challenge validation
            };

            # Only allow requests from localhost, use `ssh -L 8080:localhost:443 <server>` and a custom entry in /etc/hosts to point the url to localhost
            "/" = {
              proxyPass = "http://192.168.7.3:80";
              extraConfig = ''
                satisfy any;
                  allow ::1;
                  allow 127.0.0.1;
                deny all;
              '';
            };
          };
        };

        cfg = {
          systemd.services.keycloak.environment.KC_BOOTSTRAP_ADMIN_USERNAME = lib.mkForce "temp-admin";

          services.keycloak = {
            enable = true;

            settings = {
              hostname = "https://${config.host.services.keycloak.subdomain}.${config.host.networking.domainName}";
              hostname-admin = "https://${config.host.services.keycloak.subdomain}-admin.${config.host.networking.domainName}";
              log = "console";

              http-enabled = "true";
              proxy-headers = "xforwarded";
              proxy-trusted-addresses = config.host.networking.containerHostIP;

#              metrics-enabled = true;  # TODO
            };

            database.passwordFile = config.age.secrets.Keycloak.path;
            initialAdminPassword = "changeme";

            themes.keywind = pkgs.stdenv.mkDerivation rec {
              name = "keywind";
              src = fetchGit {
                url = "https://github.com/lukin/keywind";
                rev = "bdf966fdae0071ccd46dab4efdc38458a643b409";
              };
              installPhase = ''
                mkdir -p $out
                cp -r $src/theme/keywind/* $out/
              '';
            };
          };
        };
      }
    )
  ];
}
