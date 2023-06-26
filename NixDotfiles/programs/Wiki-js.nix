{ pkgs, config, lib, ...}: {
  services.wiki-js = {
    enable = true;

    settings.db = {
      host = "localhost";
      user = "wiki";
      pass = "UwU";
    };
  };

  services.postgresql = {
    ensureDatabases = [ "wiki" ];
    ensureUsers = [
      {
        name = "wiki";
        ensurePermissions = { "DATABASE wiki" = "ALL PRIVILEGES"; };
      }
    ];
  };

  services.nginx.virtualHosts = {
    "new-wiki.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://localhost:3000/";
      serverAliases = [ "wiki.${config.domainName}" ];
    };
  };
}