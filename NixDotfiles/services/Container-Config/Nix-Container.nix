{
  name, subdomain ? null, containerIP, containerPort, bindMounts,
  imports ? [], postgresqlName ? null, additionalDomains ? [ ], additionalContainerConfig ? {},
  makeNginxConfig ? true, additionalNginxConfig ? {}, additionalNginxLocationConfig ? {}, additionalNginxHostConfig ? {},
  cfg, lib, config, pkgs
}:
let

  utils = import ../../utils.nix { inherit lib; };
  containerPortStr = if !builtins.isString containerPort then toString containerPort else containerPort;
  stateVersion = config.system.stateVersion;

  pgImport = if postgresqlName == null then [] else [
    (
      import ./Postgresql.nix {
        inherit pkgs lib;
        name = postgresqlName;
      }
    )
  ];

  nginxImport = if makeNginxConfig == false then [] else [
    (
      import ./Nginx.nix {
        inherit containerIP config additionalDomains lib;
        containerPort = containerPortStr;
        subdomain = if subdomain != null then subdomain else name;
        additionalConfig = additionalNginxConfig;
        additionalLocationConfig = additionalNginxLocationConfig;
        additionalHostConfig = additionalNginxHostConfig;
      }
    )
  ];

in
{
  imports = imports ++ nginxImport;

  containers."${name}" = utils.recursiveMerge [
    additionalContainerConfig
    {
      autoStart = true;
      privateNetwork = true;
      hostAddress = config.containerHostIP;
      localAddress = containerIP;

      bindMounts = bindMounts;

      config = { pkgs, config, lib, ... }: utils.recursiveMerge [
        cfg
        {
          system.stateVersion = stateVersion;
          networking.firewall.allowedTCPPorts = [ containerPort ];
          imports = [ ../../users/root.nix ../../system.nix ] ++ imports ++ pgImport;
        }
      ];
    }
  ];
}
