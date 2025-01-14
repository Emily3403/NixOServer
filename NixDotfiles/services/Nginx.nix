{ pkgs, config, lib, ... }:
let
  LETSENCRYPT_EMAIL = "noanswer98+letsencrypt@gmail.com";
  utils = import ../utils.nix { inherit config lib; };
in
{
  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    commonHttpConfig = ''
        log_format main
          '$remote_addr - $remote_user [$time_local] '
          '"$request" $status $body_bytes_sent '
          '"$http_referer" "$http_user_agent" '
          'rt=$request_time uct="$upstream_connect_time" uht="$upstream_header_time" urt="$upstream_response_time"';

      access_log /var/log/nginx/access.log main;
    '';
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
      locations."/".return = "403";
    };

    ${config.host.networking.monitoringDomain} = {
      forceSSL = true;
      enableACME = true;
      locations."/".return = "403";
      basicAuthFile = config.age.secrets.Monitoring_host-htpasswd.path;
    };
  };

  age.secrets.Monitoring_host-htpasswd = {
    file = ../secrets/nixie/Monitoring/Nginx/${config.host.name}.age;
    owner = "nginx";
    group = "nginx";
  };
}
