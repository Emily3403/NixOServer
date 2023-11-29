{
  name, subdomain, containerIP, containerPort, additionalDomains ? [ ],  # TODO: Make subdomain optional
  bindMounts, cfg, config
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

    config = { pkgs, config, lib, ... }: {
      networking.firewall.allowedTCPPorts = [ containerPort ];
    } // cfg;


  };
}