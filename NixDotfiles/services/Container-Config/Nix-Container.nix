{
  name, subdomain, containerIP, containerPort, additionalDomains ? [ ],  # TODO: Make subdomain optional
  bindMounts, forwardPorts ? [], cfg, config
}:
  let containerPortStr = if !builtins.isString containerPort then toString containerPort else containerPort; in
{
  imports = [ (import ./Nginx.nix { inherit subdomain containerIP config additionalDomains; containerPort = containerPortStr; }) ];

  containers."${name}" = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = config.containerHostIP;
    localAddress = containerIP;

    bindMounts = bindMounts;
    forwardPorts = forwardPorts;

    config = { pkgs, config, lib, ... }: {
      networking.firewall.allowedTCPPorts = [ containerPort ];
    } // cfg;


  };
}