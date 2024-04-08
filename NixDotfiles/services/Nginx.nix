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

  services.nginx.virtualHosts."_" = {
    default = true;
    rejectSSL = true;
    locations."/".return = "426";
  };

  users.users.nginx.extraGroups = [ "acme" ];
}
