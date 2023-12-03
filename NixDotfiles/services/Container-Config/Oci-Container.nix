{
  name, image, subdomain ? null, containerIP, containerPort, volumes,
  imports ? [], environment ? { }, environmentFiles ? [ ], additionalContainerConfig ? {}, additionalDomains ? [ ], additionalNginxConfig ? {}, additionalNginxLocationConfig ? {},
  config, lib
}:
let

  utils = import ../../utils.nix { inherit lib; };
  containerPortStr = if !builtins.isString containerPort then toString containerPort else containerPort;

in
{
  imports = imports ++ [(
    import ./Nginx.nix {
      inherit containerIP config additionalDomains lib;
      containerPort = containerPortStr; subdomain = if subdomain != null then subdomain else name;
      additionalConfig = additionalNginxConfig; additionalLocationConfig = additionalNginxLocationConfig;
    }
  )];

  virtualisation.oci-containers.containers."${name}" = utils.recursiveMerge [ additionalContainerConfig {
    image = image;
    ports = [ "127.0.0.1::${containerPortStr}" ];
    extraOptions = [ "--ip=${containerIP}" "--userns=keep-id" ];

    volumes = volumes;
    environment = environment;
    environmentFiles = environmentFiles;
  }];
}
