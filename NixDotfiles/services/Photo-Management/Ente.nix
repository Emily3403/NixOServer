{ pkgs, pkgs-unstable, config, lib, ... }:
let
  cfg = config.host.services.ente;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  enteContainerID = 7;
  minioContainerID = 8;

  nginxWebCfg = {
    enableACME = true;
    forceSSL = true;
    root = pkgs-unstable.ente-web;
  };
in
{
  options.host.services.ente = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Ente";
    };

    api-subdomain = mkOption {
      type = types.str;
      default = "api.ente";
    };

    web-subdomain = mkOption {
      type = types.str;
      default = "ente";
    };

    albums-subdomain = mkOption {
      type = types.str;
      default = "albums";
    };

    minio-web-subdomain = mkOption {
      type = types.str;
      default = "minio.ente";
    };

    minio-api-subdomain = mkOption {
      type = types.str;
      default = "minio-api.ente";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 root"
      "d ${cfg.dataDir}/logs/ 0750 root"
      "d ${cfg.dataDir}/data/ 0750 root"
      "d ${cfg.dataDir}/minio-data/ 0750 root"
      "d ${cfg.dataDir}/cli/ 0750 root"
      "d ${cfg.dataDir}/postgresql/17/ 0750 71"

      "f ${cfg.dataDir}/museum.yaml 0640 root"
    ];

    age.secrets.Ente_Minio = {
      file = ../../secrets/${config.host.name}/Photo-Management/Ente/Minio.age;
      owner = "root";
    };

    age.secrets.Ente_Postgres = {
      file = ../../secrets/${config.host.name}/Photo-Management/Ente/Postgres.age;
      owner = "root";
    };

    environment.variables = {
      ENTE_CLI_CONFIG_PATH = "${cfg.dataDir}/cli";
      ENTE_CLI_SECRETS_PATH = "${cfg.dataDir}/cli/secrets.txt";
    };

    environment.systemPackages = [
      pkgs-unstable.ente-web
      pkgs-unstable.ente-cli
    ];

    services.nginx.virtualHosts."${cfg.web-subdomain}.${config.host.networking.domainName}" = nginxWebCfg;
    services.nginx.virtualHosts."${cfg.albums-subdomain}.${config.host.networking.domainName}" = nginxWebCfg;

    # TODO: This unit doesn't get started when the minio containers gets started...
    systemd.services."${config.virtualisation.oci-containers.backend}-ente-minio-provision" = {
      serviceConfig.Type = "oneshot";
      after = [ "${config.virtualisation.oci-containers.backend}-ente-minio.service" ];
      wants = [ "${config.virtualisation.oci-containers.backend}-ente-minio.service" ];

      # See https://github.com/ente-io/ente/blob/main/server/scripts/compose/minio-provision.sh
      script = let exec-in-container = "${pkgs.podman}/bin/podman exec -ti ente-minio"; in ''
        source ${config.age.secrets.Ente_Minio.path}

        while ! ${exec-in-container} mc config host add ente http://localhost:3200 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD
        do
           echo "waiting for minio..."
           sleep 0.5
        done

        ${exec-in-container} mc mb --ignore-existing /data/b2-eu-cen'';
    };

  };

  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        subdomain = cfg.api-subdomain;
        containerID = enteContainerID;
        dataDir = cfg.dataDir;

        name = "ente";
        image = "ghcr.io/ente-io/server:613c6a96390d7a624cf30b946955705d632423cc";
        containerPort = 8080;

#        environment = { ENVIRONMENT = "production"; };  # TODO
        postgresEnvFile = config.age.secrets.Ente_Postgres.path;

        volumes = [
          "${cfg.dataDir}/logs:/var/logs"
          "${cfg.dataDir}/data:/data:ro"
#          "${cfg.dataDir}/configurations:/configurations"
          "${cfg.dataDir}/museum.yaml:/museum.yaml:ro"
        ];
      }
    )
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        subdomain = cfg.minio-web-subdomain;
        containerID = minioContainerID;
        dataDir = cfg.dataDir;

        name = "ente-minio";
        image = "minio/minio:RELEASE.2025-02-18T16-25-55Z";

        containerPort = 3201;
        environmentFiles = [ config.age.secrets.Ente_Minio.path ];

        additionalNginxConfig = {
          locations."/".proxyWebsockets = true;
          extraConfig = "chunked_transfer_encoding off; real_ip_header X-Real-IP;";
        };

        additionalNginxHostConfig."${cfg.minio-api-subdomain}.${config.host.networking.domainName}" = {
          enableACME = true;
          forceSSL = true;
          locations."/".proxyPass = "http://${utils.makeOciContainerIP minioContainerID}:3200";
          extraConfig = ''
            chunked_transfer_encoding off;
            real_ip_header X-Real-IP;

            # Allow huge files
            client_max_body_size 10G;
            client_body_buffer_size 400M;
            proxy_max_temp_file_size 10024m;
            fastcgi_read_timeout 300s;
            fastcgi_send_timeout 300s;
            fastcgi_connect_timeout 300s;
            proxy_read_timeout 300s;
          '';
        };

        volumes = [ "${cfg.dataDir}/minio-data:/data" ];
        additionalContainerConfig.cmd = [ "server" "/data" "--address" ":3200" "--console-address" ":3201" ];
      }
    )
  ];


}
