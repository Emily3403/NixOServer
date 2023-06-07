{ pkgs, config, lib, ...}: {
  services.keycloak = {
    enable = true;

    settings = {
      hostname = "keycloak.uwu.com";
      # TODO: Split into admin console and authentification provider
      hostname-strict-backchannel = false;
      proxy = "edge";

      http-port = 1234;
      https-port = 1235;
    };

    database = {
      passwordFile = config.age.secrets.KeyCloakDatabasePassword.path;
    };

    initialAdminPassword = "UwU";  # change on first login
    sslCertificate = config.age.secrets.SSLCert.path;
    sslCertificateKey = config.age.secrets.SSLKey.path;
  };

  services.nginx.virtualHosts = {
    "keycloak.uwu.com" = {
      onlySSL = true;
      locations."/".proxyPass = "http://localhost:1234/";

      sslCertificate = config.age.secrets.SSLCert.path;
      sslCertificateKey = config.age.secrets.SSLKey.path;
    };
  };
}