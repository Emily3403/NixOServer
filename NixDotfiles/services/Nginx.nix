let
  LETSENCRYPT_EMAIL = "noanswer98+letsencrypt@gmail.com";
in

{ pkgs, config, lib, ... }: {
  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = LETSENCRYPT_EMAIL;
  };


  users.users.nginx.extraGroups = [ "acme" ];


  # Default site configuration
  services.nginx.virtualHosts = {
    "_" = {
      default = true;
      rejectSSL = true;
      locations."/".return = "426";
    };

    "${config.host.name}.status.${config.host.networking.domainName}" = {
      forceSSL = true;
      enableACME = true;
      locations."/".return = "403";
    };
  };


}
