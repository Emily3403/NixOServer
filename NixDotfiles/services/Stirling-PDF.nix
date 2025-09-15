{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.stirling-pdf;
  inherit (lib) mkIf mkOption types;

  cID = 13;
in
{
  options.host.services.stirling-pdf = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Stirling-PDF";
    };

    subdomain = mkOption {
      type = types.str;
      default = "pdf";
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 1000 1000"
      "d ${cfg.dataDir}/training-data/ 0750 1000 1000"
      "d ${cfg.dataDir}/configs/ 0750 1000 1000"
      "d ${cfg.dataDir}/custom-files/ 0750 1000 1000"
      "d ${cfg.dataDir}/logs/ 0750 1000 1000"
      "d ${cfg.dataDir}/pipeline/ 0750 1000 1000"
    ];

    age.secrets.Stirling-PDF = {
      file = ../secrets/nixie/Stirling-PDF.age;
      owner = "1000";
    };
  };

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs cID;
        dataDir = cfg.dataDir;
        subdomain = cfg.subdomain;

        name = "stirling-pdf";
        image = "stirlingtools/stirling-pdf:0.43.1";
        containerPort = 8080;

        additionalNginxConfig.extraConfig = "client_max_body_size 1G;";  # 1G of PDF should be enough

        environmentFiles = [ config.age.secrets.Stirling-PDF.path ];
        environment = {
          SYSTEM_ROOTURIPATH = "/";
          INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true";
          LANGS = "en_US";

          DOCKER_ENABLE_SECURITY = "true";
          SECURITY_ENABLELOGIN = "true";

          SYSTEM_SHOWUPDATE = "true";
          SYSTEM_SHOWUPDATEONLYTOADMIN = "true";
          SYSTEM_ENABLEANALYTICS = "false";

          SECURITY_LOGINMETHOD = "oauth2";
          SECURITY_OAUTH2_ENABLED = "true";
          SECURITY_OAUTH2_CLIENT_KEYCLOAK_ISSUER = "https://kc.ruwusch.de/realms/Super-Realm"; # TODO: This keycloak setup should be the subdomain of ruwusch, not hardcoded
          SECURITY_OAUTH2_CLIENT_KEYCLOAK_CLIENTID = "Stirling-PDF";
          SECURITY_OAUTH2_CLIENT_KEYCLOAK_USEASUSERNAME = "preferred_username";

          SECURITY_OAUTH2_AUTOCREATEUSER = "true";
          SECURITY_OAUTH2_PROVIDER = "keycloak";
        };

        volumes = [
          "${cfg.dataDir}/training-data:/usr/share/tessdata"
          "${cfg.dataDir}/configs:/configs"
          "${cfg.dataDir}/custom-files:/customFiles"
          "${cfg.dataDir}/logs:/logs"
          "${cfg.dataDir}/pipeline:/pipeline"
        ];
      }
    )
  ];

}
