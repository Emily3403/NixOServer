{ pkgs, config, lib, ...}: {
  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };


  security.acme = {
    acceptTerms = true;
    defaults.email = "noanswer98+letsencrypt@gmail.com";
  };

  users.users.nginx.extraGroups = [ "acme" ];

}
