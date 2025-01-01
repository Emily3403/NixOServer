{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Stirling-PDF"; in
{

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        name = "stirling-pdf";
        image = "stirlingtools/stirling-pdf:latest";
        dataDir = DATA_DIR;

        subdomain = "pdf";
        containerIP = "10.88.7.1";
        containerPort = 8080;

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
          SECURITY_OAUTH2_CLIENT_KEYCLOAK_ISSUER = "https://${config.keycloak-setup.subdomain}.${config.keycloak-setup.domain}/realms/${config.keycloak-setup.realm}";
          SECURITY_OAUTH2_CLIENT_KEYCLOAK_CLIENTID = "Stirling-PDF";
          SECURITY_OAUTH2_CLIENT_KEYCLOAK_USEASUSERNAME = "preferred_username";
#         Set via secrets: SECURITY_OAUTH2_CLIENT_KEYCLOAK_CLIENTSECRET
          SECURITY_OAUTH2_AUTOCREATEUSER = "true";
          SECURITY_OAUTH2_PROVIDER = "keycloak";
        };

        volumes = [
          "${DATA_DIR}/training-data:/usr/share/tessdata"
          "${DATA_DIR}/configs:/configs"
          "${DATA_DIR}/custom-files:/customFiles"
          "${DATA_DIR}/logs:/logs"
          "${DATA_DIR}/pipeline:/pipeline"
        ];
      }
    )
  ];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 1000 1000"
    "d ${DATA_DIR}/training-data/ 0750 1000 1000"
    "d ${DATA_DIR}/configs/ 0750 1000 1000"
    "d ${DATA_DIR}/custom-files/ 0750 1000 1000"
    "d ${DATA_DIR}/logs/ 0750 1000 1000"
    "d ${DATA_DIR}/pipeline/ 0750 1000 1000"
  ];
}
