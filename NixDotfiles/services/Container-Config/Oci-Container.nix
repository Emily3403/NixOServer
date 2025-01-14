{ enable ? true
, createPod ? true
, name
, image
, dataDir
, subdomain ? null
, fqdn ? null
, containerID
, containerPort /* int */
, volumes ? []
, makeLocaltimeVolume ? true
, additionalContainers ? { }
, imports ? [ ]
, environment ? { }
, environmentFiles ? [ ]
, postgresEnvFile ? null
, mysqlEnvFile ? null
, redisEnvFile ? null
, additionalPorts ? [ ]
, additionalPodCreationArgs ? ""
, additionalDomains ? [ ]
, additionalContainerConfig ? { }
, makeNginxConfig ? true
, nginxUseHttps ? false
, nginxLocation ? "/"
, nginxProxyPassLocation ? "/"
, additionalNginxConfig ? { }
, additionalNginxLocationConfig ? { }
, additionalNginxHostConfig ? { }
, config
, lib
, pkgs
}:
let

  inherit (lib) mkIf optional optionals;
  utils = import ../../utils.nix { inherit config lib; };

  containerIP = utils.makeOciContainerIP containerID;
  defVolumes = [ "/etc/resolv.conf:/etc/resolv.conf:ro" ] ++ optional makeLocaltimeVolume "/etc/localtime:/etc/localtime:ro";

  podName = "pod-${name}";

in
{
  imports = imports ++ [(
    import ./Nginx.nix {
      inherit containerIP fqdn config additionalDomains lib containerPort;
      enable = enable && makeNginxConfig;
      subdomain = if subdomain != null then subdomain else name;
      useHttps = nginxUseHttps;
      location = nginxLocation;
      proxyPassLocation = nginxProxyPassLocation;
      additionalConfig = additionalNginxConfig;
      additionalLocationConfig = additionalNginxLocationConfig;
      additionalHostConfig = additionalNginxHostConfig;
    }
  )];

  # TODO: Throw an error for docker as the backend.
  systemd.services."create-pod-${name}" = mkIf (enable && createPod) {
    serviceConfig.Type = "oneshot";
    wantedBy = [ "podman-${name}.service" ];

    # TODO: Only create the pod with neccessary ports. Also check if the ports are correctly set, if not rebuild the pod.
    script = ''
      ${pkgs.podman}/bin/podman pod exists ${podName} || \
      ${pkgs.podman}/bin/podman pod create --name=${podName} --ip=${containerIP} --userns=keep-id \
        -p 127.0.0.1::${toString containerPort} -p 127.0.0.1::5432 -p 127.0.0.1::6379 ''
    + (builtins.concatStringsSep " " (builtins.map (it: "-p ${it}") additionalPorts))
    + " " + additionalPodCreationArgs
    ;

  };

  virtualisation.oci-containers.containers = mkIf enable {
    "${name}" = utils.recursiveMerge [
      additionalContainerConfig
      {
        image = image;
        extraOptions = optional createPod "--pod=${podName}";

        volumes = volumes ++ defVolumes;
        environment = { TZ = config.host.networking.timeZone; } // environment;
        environmentFiles = environmentFiles;
      }
    ];

    # TODO: Throw errors if trying to create postgres / other containers when createPod=false
    "${name}-postgres" = mkIf (postgresEnvFile != null) {
      image = "postgres:17-alpine";
      extraOptions = [ "--pod=${podName}" ];

      environment = { POSTGRES_DB = name; };
      environmentFiles = [ postgresEnvFile ];
      volumes = [ "${dataDir}/postgresql/17:/var/lib/postgresql/data" ] ++ defVolumes;
      cmd = [ "-h" "127.0.0.1" ];
    };

    "${name}-mysql" = mkIf (mysqlEnvFile != null) {
      image = "linuxserver/mariadb:10.11.6";
      extraOptions = [ "--pod=${podName}" ];

      environment = {
        PUID = "40${toString containerID}";  # TODO: This is terrible. I need padding on the string
        PGID = "40${toString containerID}";
        TZ = config.host.networking.timeZone;
        MYSQL_USER = name;
        MYSQL_DATABASE = name;
      };

      environmentFiles = [ mysqlEnvFile ];
      volumes = [
        "${dataDir}/mysql:/config"
#        "/etc/mysql/custom.cnf:/config/custom.cnf"  # TODO: This is currently the only way to enable bind-address = 127.0.0.1. But when this is enabled, onlyoffice fails to connect to the database.
      ] ++ defVolumes;

    };

    "${name}-redis" = mkIf (redisEnvFile != null) {
      image = "redis:7.2.4-alpine";
      extraOptions = [ "--pod=${podName}" ];

      environmentFiles = [ redisEnvFile ];
      volumes = [ "${dataDir}/redis:/data" ] ++ defVolumes;
      cmd = [ "--bind" "127.0.0.1" ];

      # Currently, there is no password authentication.
      # This is not that big of an issue due to the fact that every container group (pod) has their own postgres / redis instance.
      # In the future, this assumption might change. Thus, we may want to work on implementing a password authentication.
      # The current issue holding us back is that the redis container doesn't want to substitute the environment variable. If that can be fixed, password authentication should be trivial.
      # cmd = [ "--requirepass" "$REDIS_PASSWORD" ];
    };
  } // additionalContainers;

  environment.etc = mkIf (mysqlEnvFile != null) {
    "mysql/custom.cnf".text = ''
      [mysqld]
      bind-address = "127.0.0.1"
      user=abc
    '';
  };

  systemd.tmpfiles.rules = optionals (enable && postgresEnvFile != null) [
    "d ${dataDir}/postgresql/ 0750 70"  # TODO: This currently only works when the top dir is owned by root
    "d ${dataDir}/postgresql/17/ 0750 70"
  ] ++ optionals (enable && redisEnvFile != null) [
    "d ${dataDir}/redis/ 0750 999"
  ] ++ optionals (enable && mysqlEnvFile != null) [
    "d ${dataDir}/mysql/ 0750 40${toString containerID}"
  ];

}
