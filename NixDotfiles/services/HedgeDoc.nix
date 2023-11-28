let

  SUBDOMAIN = "doc";
  CONTAINER_IP = "192.168.7.104";
  CONTAINER_PORT = 3000;
  DATA_DIR = "/data/Keycloak";

  KEYCLOAK_CLIENT = "HedgeDoc";

in

{ pkgs, config, lib, ... }: {

  imports = [ ../users/services/hedgedoc.nix ];

  services.nginx.virtualHosts = {
    "doc.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://${CONTAINER_IP}:${toString CONTAINER_PORT}/";
      serverAliases = [ "pad.${config.domainName}" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/postgresql 0755 postgres"
    "d ${DATA_DIR}/hedgedoc 0755 hedgedoc"
  ];

  containers.hedgedoc = let cfg = config; in {

    autoStart = true;
    privateNetwork = true;
    hostAddress = config.containerHostIP;
    localAddress = "${CONTAINER_IP}";

    bindMounts = {
      "/var/lib/hedgedoc/" = { hostPath = "${DATA_DIR}/hedgedoc"; isReadOnly = false; };
      "/var/lib/postgresql" = { hostPath = "${DATA_DIR}/postgresql"; isReadOnly = false; };
      "${cfg.age.secrets.HedgeDoc_EnvironmentFile.path}" = { hostPath = cfg.age.secrets.HedgeDoc_EnvironmentFile.path; };
    };

    config = { pkgs, config, lib, ... }: {
      networking.firewall.allowedTCPPorts = [ CONTAINER_PORT ];
      imports = [
        ../users/root.nix
        ../users/services/hedgedoc.nix
        ../system.nix
        (import ./Container-Config/Postgresql.nix { dbName = "hedgedoc"; dbUser = "hedgedoc"; pkgs = pkgs; })
      ];

      services.hedgedoc = {
        enable = true;
        environmentFile = cfg.age.secrets.HedgeDoc_EnvironmentFile.path;

        settings = {
          domain = "doc.${cfg.domainName}";
          allowOrigin = [ "localhost" "pad.${cfg.domainName}" ];
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
            providerName = cfg.keycloak-setup.name;
            clientID = KEYCLOAK_CLIENT;
            clientSecret = "$CLIENT_SECRET";

            authorizationURL = "https://${cfg.keycloak-setup.subdomain}.${cfg.keycloak-setup.domain}/realms/${cfg.keycloak-setup.realm}/protocol/openid-connect/auth";
            tokenURL = "https://${cfg.keycloak-setup.subdomain}.${cfg.keycloak-setup.domain}/realms/${cfg.keycloak-setup.realm}/protocol/openid-connect/token";
            baseURL = "${cfg.keycloak-setup.subdomain}.${cfg.keycloak-setup.domain}";
            userProfileURL = "https://${cfg.keycloak-setup.subdomain}.${cfg.keycloak-setup.domain}/realms/${cfg.keycloak-setup.realm}/protocol/openid-connect/userinfo";

            userProfileUsernameAttr = cfg.keycloak-setup.attributeMapper.username;
            userProfileDisplayNameAttr = cfg.keycloak-setup.attributeMapper.name;
            userProfileEmailAttr = cfg.keycloak-setup.attributeMapper.email;
            #            scope = "openid email profile";
            rolesClaim = cfg.keycloak-setup.attributeMapper.groups;
            #            accessRole = "";
          };
        };
      };
    };
  };
}
