{
  name, image,
  subdomain, containerIP, containerPort,
  volumes, environment ? {}, environmentFiles ? [], additionalPorts ? [], additionalOptions ? [], config
}:
  let containerPortStr = if !builtins.isString containerPort then toString containerPort else containerPort; in
{
  imports = [( import ./Nginx.nix { inherit subdomain containerIP config; containerPort=containerPortStr; }) ];

  virtualisation.oci-containers.containers."${name}" = {
    image = image;
    ports = additionalPorts ++ (if (builtins.match (".*${containerPortStr}.*" additionalPorts) != null ) then [] else [ "127.0.0.1::${containerPortStr}" ]);
    extraOptions = [ "--ip=${containerIP}" "--userns=keep-id" ] ++ additionalOptions;

    volumes = volumes;
    environment = environment;
    environmentFiles = environmentFiles;
  };
}
