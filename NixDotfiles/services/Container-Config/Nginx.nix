{subdomain, containerIP, containerPort /* str */, config}: {
  services.nginx.virtualHosts = {
    "${subdomain}.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://${containerIP}:${containerPort}/";
    };
  };
}