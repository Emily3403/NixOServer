{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Hedgedoc"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/hedgedoc 0755 hedgedoc"
    "d ${DATA_DIR}/postgresql 0755 postgres"
  ];

  imports = [(
    import ./Container-Config/Nix-Container.nix {
      inherit config lib;
      name = "hedgedoc";
      subdomain = "doc";
      additionalDomains = [ "pad" ];
      containerIP = "192.168.7.104";
      containerPort = 3000;

      imports = [ ../users/services/hedgedoc.nix ];
      bindMounts = {
        "/var/lib/hedgedoc/" = { hostPath = "${DATA_DIR}/hedgedoc"; isReadOnly = false; };
        "/var/lib/postgresql" = { hostPath = "${DATA_DIR}/postgresql"; isReadOnly = false; };
        "${config.age.secrets.HedgeDoc_EnvironmentFile.path}".hostPath = config.age.secrets.HedgeDoc_EnvironmentFile.path;
      };

      cfg = {
        imports = [( import ./Container-Config/Postgresql.nix { dbName = "hedgedoc"; dbUser = "hedgedoc"; pkgs = pkgs; } )];

        services.hedgedoc = {
        enable = true;
        environmentFile = config.age.secrets.HedgeDoc_EnvironmentFile.path;

        settings = {
          domain = "doc.${config.domainName}";
          allowOrigin = [ "localhost" "pad.${config.domainName}" ];
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
            providerName = config.keycloak-setup.name;
            clientID = "HedgeDoc";
            clientSecret = "$CLIENT_SECRET";

            authorizationURL = "https://${config.keycloak-setup.subdomain}.${config.keycloak-setup.domain}/realms/${config.keycloak-setup.realm}/protocol/openid-connect/auth";
            tokenURL = "https://${config.keycloak-setup.subdomain}.${config.keycloak-setup.domain}/realms/${config.keycloak-setup.realm}/protocol/openid-connect/token";
            baseURL = "${config.keycloak-setup.subdomain}.${config.keycloak-setup.domain}";
            userProfileURL = "https://${config.keycloak-setup.subdomain}.${config.keycloak-setup.domain}/realms/${config.keycloak-setup.realm}/protocol/openid-connect/userinfo";

            userProfileUsernameAttr = config.keycloak-setup.attributeMapper.username;
            userProfileDisplayNameAttr = config.keycloak-setup.attributeMapper.name;
            userProfileEmailAttr = config.keycloak-setup.attributeMapper.email;
            # scope = "openid email profile";
            rolesClaim = config.keycloak-setup.attributeMapper.groups;
            # accessRole = "";
          };
        };
      };
      };
    }
  )];
}
