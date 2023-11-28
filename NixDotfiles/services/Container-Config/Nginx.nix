{ subdomain, containerIP, containerPort /* str */, additionalDomains ? [ ], extraConfig ? "", config }: {
  services.nginx.virtualHosts = {
    "${subdomain}.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://${containerIP}:${containerPort}/";
      serverAliases = map (it: "${it}.${config.domainName}") additionalDomains;
      extraConfig = extraConfig;
    };
  };
}
