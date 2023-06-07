{ pkgs, config, lib, ...}: {
  services.wiki-js = {
    enable = true;

    settings.db = {
      host = "localhost";
      user = "wikijs";
      pass = "UwU";
    };

    settings.logLevel = "silly";

    environmentFile = "/root/wiki-js.env";
  };

  services.postgresql = {
    ensureDatabases = [ "wiki" ];
    ensureUsers = [
      {
        name = "wikijs";
        ensurePermissions = { "DATABASE wiki" = "ALL PRIVILEGES"; };
      }
    ];
  };

  services.nginx.virtualHosts = {
    "wiki.uwu.com" = {
      onlySSL = true;
      locations."/".proxyPass = "http://localhost:3000/";

      sslCertificate = config.age.secrets.SSLCert.path;
      sslCertificateKey = config.age.secrets.SSLKey.path;
    };
  };
}