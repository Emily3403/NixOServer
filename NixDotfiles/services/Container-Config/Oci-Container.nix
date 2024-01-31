{
  name, image, subdomain ? null, containerIP, containerPort, volumes,
  imports ? [], environment ? { }, environmentFiles ? [ ], additionalContainerConfig ? {}, additionalDomains ? [ ],
  makeNginxConfig ? true, additionalNginxConfig ? {}, additionalNginxLocationConfig ? {}, additionalNginxHostConfig ? {},
  config, lib
}:
let

  utils = import ../../utils.nix { inherit lib; };
  containerPortStr = if !builtins.isString containerPort then toString containerPort else containerPort;

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

  virtualisation.oci-containers.containers."${name}" = utils.recursiveMerge [
    additionalContainerConfig
    {
      image = image;
      ports = [ "127.0.0.1::${containerPortStr}" ];
      extraOptions = [ "--ip=${containerIP}" "--userns=keep-id" ];

      volumes = volumes ++ [ "/etc/resolv.conf:/etc/resolv.conf:ro" ];
      environment = environment;
      environmentFiles = environmentFiles;
    }
  ];
}
