{ enable
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
, redisEnvFile ? null
, additionalContainerConfig ? { }
, additionalDomains ? [ ]
, makeNginxConfig ? true
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
        -p 127.0.0.1::${containerPortStr} -p 127.0.0.1::5432 -p 127.0.0.1::6379 -p 127.0.0.1::3200
    '';
  };

  virtualisation.oci-containers.containers = mkIf enable
    {
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

      "${name}-redis" = mkIf (redisEnvFile != null) {
        image = "redis:7.2.4-alpine";
        extraOptions = [ "--pod=${podName}" ];

        environmentFiles = [ redisEnvFile ];
        volumes = [ "${dataDir}/redis:/data" ] ++ defVolumes;
        cmd = [ "--bind" "127.0.0.1" ];
      };
    } // additionalContainers;

  systemd.tmpfiles.rules = optionals (enable && postgresEnvFile != null) [
    "d ${dataDir}/postgresql/ 0750 70" # TODO: This currently only works when the top dir is owned by root
    "d ${dataDir}/postgresql/17/ 0750 70"
  ] ++ optionals (enable && redisEnvFile != null) [
    "d ${dataDir}/redis/ 0750 999"
  ];
}
