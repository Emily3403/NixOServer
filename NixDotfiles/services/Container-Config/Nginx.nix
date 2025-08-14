{ enable ? true
, subdomain
, fqdn ? null
, location ? "/"
, proxyPassLocation ? "/"
, containerIP
, containerPort /* int */
, useHttps ? false
, maxUploadSize ? "10M"
, additionalDomains ? [ ]
, additionalConfig ? { }
, additionalLocationConfig ? { }
, additionalHostConfig ? { }
, config
, lib
}:
let

  inherit (lib) mkIf;
  utils = import ../../utils.nix { inherit config lib; };

  domain = if fqdn != null then fqdn else "${subdomain}.${config.host.networking.domainName}";
in
{
  services.nginx = mkIf enable {

    virtualHosts = utils.recursiveMerge [
      additionalHostConfig
      {
        ${domain} = utils.recursiveMerge [
          additionalConfig
          {
            forceSSL = true;
            enableACME = true;
            serverAliases = map (it: "${it}.${config.host.networking.domainName}") additionalDomains;

            locations."${location}" = utils.recursiveMerge [
              additionalLocationConfig
              {
                proxyPass = (if useHttps then "https" else "http") + "://${containerIP}:${toString containerPort}${proxyPassLocation}";
              }
            ];
          }
        ];
      }
    ];
  };
}
