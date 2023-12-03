{
  name, subdomain, containerIP, containerPort, additionalDomains ? [ ],  # TODO: Make subdomain optional
  imports ? [], bindMounts, forwardPorts ? [], proxyWebsockets ? false, cfg, config
}:
  let containerPortStr = if !builtins.isString containerPort then toString containerPort else containerPort; in
{
  imports = imports ++ [ (import ./Nginx.nix { inherit subdomain containerIP config additionalDomains proxyWebsockets; containerPort = containerPortStr; }) ];

  containers."${name}" = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = config.containerHostIP;
    localAddress = containerIP;

    bindMounts = bindMounts;
    forwardPorts = forwardPorts;

    config = { pkgs, config, lib, ... }:
    # Default config, may be overwritten
    {
      networking.firewall.allowedTCPPorts = [ containerPort ];
    }
    // cfg //
    # Additional config, overwrites cfg
    {
      imports = cfg.imports ++ imports ++ [ ../../users/root.nix ../../system.nix ];
    };


  };
}