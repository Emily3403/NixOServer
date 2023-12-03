{
  subdomain, containerIP, containerPort /* str */,
  additionalDomains ? [ ], extraConfig ? "", proxyWebsockets ? false,
  config
}: {
  services.nginx.virtualHosts = {
    "${subdomain}.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://${containerIP}:${containerPort}/";
      locations."/".proxyWebsockets = proxyWebsockets;
      serverAliases = map (it: "${it}.${config.domainName}") additionalDomains;
      extraConfig = extraConfig;
    };
  };
}
