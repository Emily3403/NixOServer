{ enable ? true
, name
, image
, dataDir
, subdomain ? null
, containerID
, containerPort
, volumes
, makeLocaltimeVolume ? true
, additionalContainers ? { }
, imports ? [ ]
, environment ? { }
, environmentFiles ? [ ]
, postgresEnvFile ? null
, mysqlEnvFile ? null
, redisEnvFile ? null
, additionalPorts ? [ ]
, additionalDomains ? [ ]
, additionalContainerConfig ? { }
, makeNginxConfig ? true
, nginxUseHttps ? false
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

  containerIP = "10.88.1.${toString (containerID + 1)}";
  containerPortStr = if !builtins.isString containerPort then toString containerPort else containerPort;
  defVolumes = [ "/etc/resolv.conf:/etc/resolv.conf:ro" ] ++ optional makeLocaltimeVolume "/etc/localtime:/etc/localtime:ro";

  podName = "pod-${name}";

  nginxImport = if enable == false || makeNginxConfig == false then [ ] else [
    (
      import ./Nginx.nix {
        inherit containerIP config additionalDomains lib;
        containerPort = containerPortStr;
        subdomain = if subdomain != null then subdomain else name;
        useHttps = nginxUseHttps;
        additionalConfig = additionalNginxConfig;
        additionalLocationConfig = additionalNginxLocationConfig;
        additionalHostConfig = additionalNginxHostConfig;
      }
    )
  ];

in
{
  imports = imports ++ nginxImport;

  systemd.services."create-pod-${name}" = mkIf enable {
    serviceConfig.Type = "oneshot";
    wantedBy = [ "${config.virtualisation.oci-containers.backend}-${name}.service" ];
    script = ''
      ${pkgs.podman}/bin/podman pod exists ${podName} || \
      ${pkgs.podman}/bin/podman pod create --name=${podName} --ip=${containerIP} --userns=keep-id \
        -p 127.0.0.1::${containerPortStr} -p 127.0.0.1::5432 -p 127.0.0.1::6379 ''
    + (builtins.concatStringsSep " " (builtins.map (it: "-p ${it}") additionalPorts))
    ;

  };

  virtualisation.oci-containers.containers = mkIf enable {
    "${name}" = utils.recursiveMerge [
      additionalContainerConfig
      {
        image = image;
        extraOptions = [ "--pod=${podName}" ];

        volumes = volumes ++ defVolumes;
        environment = { TZ = "Europe/Berlin"; } // environment;
        environmentFiles = environmentFiles;
      }
    ];

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
        PUID = "400${toString containerID}";
        PGID = "400${toString containerID}";
        TZ = "Europe/Berlin";
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
    "d ${dataDir}/mysql/ 0750 4001"
  ];

}
