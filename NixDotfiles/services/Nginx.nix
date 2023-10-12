{ pkgs, config, lib, ...}: {
  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "nixie.${config.domainName}" = {
        forceSSL = true;
        enableACME = true;

        locations."/".proxyPass = "http://192.168.7.102:3000/";
      };
    };
  };


  security.acme = {
    acceptTerms = true;
    defaults.email = "nixie3403@gmail.com";
  };

  users.users.nginx.extraGroups = [ "acme" ];


  services.nginx.virtualHosts."${config.domainName}" = {
    forceSSL = true;
    enableACME = true;

    globalRedirect = "tu.berlin/eninet";
  };

}
