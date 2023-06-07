{ pkgs, config, lib, ...}: {
  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "localhost" = {

        serverAliases = [  ];
        locations."/" = {
          proxyPass = "http://localhost:1234/";
        };
      };
    };
  };


  security.acme = {
    acceptTerms = true;

    defaults.email = "emily.seebeck3403@gmail.com";
    defaults.server = "https://acme-staging-v02.api.letsencrypt.org";
  };

}
