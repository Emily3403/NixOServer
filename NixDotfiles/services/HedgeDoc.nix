{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.hedgedoc;
  kcfg = config.host.services.keycloak;
  utils = import ../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  cID = 4;
in
{
  options.host.services.hedgedoc = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/HedgeDoc";
    };

    subdomain = mkOption {
      type = types.str;
      default = "pad";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 hedgedoc"
      "d ${cfg.dataDir}/hedgedoc 0750 hedgedoc"
      "d ${cfg.dataDir}/postgresql 0750 postgres"
    ];

    age.secrets.HedgeDoc = {
      file = ../secrets/${config.host.name}/HedgeDoc.age;
      owner = "hedgedoc";
    };
  };


  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs cID;
        subdomain = cfg.subdomain;

        name = "hedgedoc";
        containerPort = 3000;
        isSystemUser = true;

        nginxMaxUploadSize = "100M";
        additionalNginxConfig.locations = {
          "/metrics".return = "403";
          "/status".return = "403";
        };

        postgresqlName = "hedgedoc";
        bindMounts = {
          "/var/lib/hedgedoc/" = { hostPath = "${cfg.dataDir}/hedgedoc"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${cfg.dataDir}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.HedgeDoc.path}".hostPath = config.age.secrets.HedgeDoc.path;
        };

        cfg.services.hedgedoc = {
          enable = true;
          environmentFile = config.age.secrets.HedgeDoc.path;

          settings = {
            domain = "${cfg.subdomain}.${config.host.networking.domainName}";
            allowOrigin = [ "localhost" "${cfg.subdomain}.${config.host.networking.domainName}" ];
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
              providerName = kcfg.name;
              clientID = "HedgeDoc";
              clientSecret = "$CLIENT_SECRET";

              authorizationURL = "https://${kcfg.subdomain}.${kcfg.domain}/realms/${kcfg.realm}/protocol/openid-connect/auth";
              tokenURL = "https://${kcfg.subdomain}.${kcfg.domain}/realms/${kcfg.realm}/protocol/openid-connect/token";
              baseURL = "${kcfg.subdomain}.${kcfg.domain}";
              userProfileURL = "https://${kcfg.subdomain}.${kcfg.domain}/realms/${kcfg.realm}/protocol/openid-connect/userinfo";

              userProfileUsernameAttr = kcfg.attributeMapper.username;
              userProfileDisplayNameAttr = kcfg.attributeMapper.name;
              userProfileEmailAttr = kcfg.attributeMapper.email;
              scope = "openid email profile";
              rolesClaim = kcfg.attributeMapper.groups;
            };
          };
        };
      }
    )
  ];

  config.services.nginx.virtualHosts."${config.host.networking.monitoringDomain}" = mkIf cfg.enableExporter (utils.makeNginxMetricConfig "hedgedoc" (utils.makeNixContainerIP cID) "3000");
}
