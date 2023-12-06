{
  subdomain, containerIP, containerPort /* str */,
  additionalDomains ? [ ], additionalConfig ? {}, additionalLocationConfig ? {}, additionalHostConfig ? {},
  config, lib
}:
let utils = import ../../utils.nix { inherit lib; }; in
{
  services.nginx.virtualHosts = utils.recursiveMerge [
    additionalHostConfig
    {
      "${subdomain}.${config.domainName}" = utils.recursiveMerge [
        additionalConfig
        {
          forceSSL = true;
          enableACME = true;
          serverAliases = map (it: "${it}.${config.domainName}") additionalDomains;

          locations."/" = utils.recursiveMerge [
            additionalLocationConfig
            {
              proxyPass = "http://${containerIP}:${containerPort}/";
            }
          ];
        }
      ];
    }
  ];
}
