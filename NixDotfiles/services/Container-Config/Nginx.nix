{ subdomain
, location ? "/"
, containerIP
, containerPort /* str */
, useHttps ? false
, additionalDomains ? [ ]
, additionalConfig ? { }
, additionalLocationConfig ? { }
, additionalHostConfig ? { }
, config
, lib
}:
let utils = import ../../utils.nix { inherit config lib; }; in
{
  services.nginx.virtualHosts = utils.recursiveMerge [
    additionalHostConfig
    {
      "${subdomain}.${config.host.networking.domainName}" = utils.recursiveMerge [
        additionalConfig
        {
          forceSSL = true;
          enableACME = true;
          serverAliases = map (it: "${it}.${config.host.networking.domainName}") additionalDomains;

          locations."${location}" = utils.recursiveMerge [
            additionalLocationConfig
            {
              proxyPass = (if useHttps then "https" else "http") + "://${containerIP}:${containerPort}/";
            }
          ];
        }
      ];
    }
  ];
}
