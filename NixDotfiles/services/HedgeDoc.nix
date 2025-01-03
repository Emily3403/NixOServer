{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Hedgedoc"; in
{
  systemd.tmpfiles.rules = [
    "d ${cfg.dataDir} 0750 hedgedoc"
    "d ${cfg.dataDir}/hedgedoc 0750 hedgedoc"
    "d ${cfg.dataDir}/postgresql 0750 postgres"
  ];

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "hedgedoc";
        subdomain = "pad";
        containerIP = "192.168.7.104";
        containerPort = 3000;

        additionalNginxConfig.locations = {
          "/metrics".return = "403";
          "/status".return = "403";
        };

        postgresqlName = "hedgedoc";
        imports = [ ../users/services/hedgedoc.nix ];
        bindMounts = {
          "/var/lib/hedgedoc/" = { hostPath = "${cfg.dataDir}/hedgedoc"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${cfg.dataDir}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.HedgeDoc_EnvironmentFile.path}".hostPath = config.age.secrets.HedgeDoc_EnvironmentFile.path;
        };

        cfg.services.hedgedoc = {
          enable = true;
          environmentFile = config.age.secrets.HedgeDoc_EnvironmentFile.path;

          settings = {
            domain = "pad.${config.host.networking.domainName}";
            allowOrigin = [ "localhost" "pad.${config.host.networking.domainName}" ];
            host = "0.0.0.0";
            protocolUseSSL = true;

            db = {
              dialect = "postgres";
              host = "/run/postgresql";
            };

            # Users and Permissions
            email = false;
            allowAnonymous = true;
            allowAnonymousEdits = true;
            allowEmailRegister = false;
            allowFreeURL = true;
            requireFreeURLAuthentication = true;
            defaultPermission = "limited";

            # Authentication
            sessionSecret = "$SESSION_SECRET";
            oauth2 = {
              providerName = config.host.services.keycloak.name;
              clientID = "HedgeDoc";
              clientSecret = "$CLIENT_SECRET";

              authorizationURL = "https://${config.host.services.keycloak.subdomain}.${config.host.services.keycloak.domain}/realms/${config.host.services.keycloak.realm}/protocol/openid-connect/auth";
              tokenURL = "https://${config.host.services.keycloak.subdomain}.${config.host.services.keycloak.domain}/realms/${config.host.services.keycloak.realm}/protocol/openid-connect/token";
              baseURL = "${config.host.services.keycloak.subdomain}.${config.host.services.keycloak.domain}";
              userProfileURL = "https://${config.host.services.keycloak.subdomain}.${config.host.services.keycloak.domain}/realms/${config.host.services.keycloak.realm}/protocol/openid-connect/userinfo";

              userProfileUsernameAttr = config.host.services.keycloak.attributeMapper.username;
              userProfileDisplayNameAttr = config.host.services.keycloak.attributeMapper.name;
              userProfileEmailAttr = config.host.services.keycloak.attributeMapper.email;
              scope = "openid email profile";
              rolesClaim = config.host.services.keycloak.attributeMapper.groups;
              # accessRole = "";
            };
          };
        };
      }
    )
  ];
}
