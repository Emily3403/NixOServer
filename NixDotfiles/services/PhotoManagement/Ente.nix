{ pkgs, pkgs-unstable, config, lib, ... }:
let
DATA_DIR = "/data/Ente";
in
{

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0777 root"  # TODO
    "d ${DATA_DIR}/logs/ 0777 root"
    "d ${DATA_DIR}/data/ 0777 root"
    "d ${DATA_DIR}/minio-data/ 0750 root"
    "d ${DATA_DIR}/cli/ 0750 root"
    "d ${DATA_DIR}/postgresql/15/ 0750 71"

    "f ${DATA_DIR}/museum.yaml 0640 root"
  ];

  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        name = "ente";
        image = "ghcr.io/ente-io/server";
        subdomain = "api.ente";
        dataDir = DATA_DIR;

        containerIP = "10.88.6.1";
        containerPort = 8080;
#        environment = { ENVIRONMENT = "production"; };  # TODO
        postgresEnvFile = config.age.secrets.Ente_Postgres.path;

        volumes = [
          "${DATA_DIR}/logs:/var/logs"
          "${DATA_DIR}/data:/data:ro"
          "${DATA_DIR}/museum.yaml:/museum.yaml:ro"
        ];

        additionalContainers.ente-minio = {
          image = "minio/minio";
          extraOptions = [ "--pod=pod-ente" ];
          environmentFiles = [ config.age.secrets.Ente_Minio.path ];
          volumes = [ "${DATA_DIR}/minio-data:/data"  ];
          cmd = ["server" "/data" "--address" ":3200" "--console-address" ":3201"];
        };
      }
    )
  ];

  # MinIO
  services.nginx.virtualHosts."minio.ente.${config.domainName}" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://10.88.6.1:3201";
    extraConfig = ''
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;

      proxy_connect_timeout 300;
      # Default is HTTP/1, keepalive is only enabled in HTTP/1.1
      proxy_http_version 1.1;
      proxy_set_header Connection "";
      chunked_transfer_encoding off;
    '';
  };

  services.nginx.virtualHosts."minio-api.ente.${config.domainName}" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://10.88.6.1:3200";
    extraConfig = ''
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-NginX-Proxy true;

      # This is necessary to pass the correct IP to be hashed
      real_ip_header X-Real-IP;

      proxy_connect_timeout 300;

      # To support websockets in MinIO versions released after January 2023
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";

      # Allow huge files
      client_max_body_size 10G;
      client_body_buffer_size 400M;
      proxy_max_temp_file_size 10024m;
      fastcgi_read_timeout 3600s;
      fastcgi_send_timeout 3600s;
      fastcgi_connect_timeout 3600s;
      proxy_read_timeout 3600s;

      chunked_transfer_encoding off;
    '';
  };

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


  # Ente Web
  services.nginx.virtualHosts."ente.${config.domainName}" = {
    enableACME = true;
    forceSSL = true;
    root = pkgs-unstable.ente-web;
#    extraConfig = NGINX_HEADERS;
  };

  environment.variables = {
    ENTE_CLI_CONFIG_PATH = "${DATA_DIR}/cli";
    ENTE_CLI_SECRETS_PATH = "${DATA_DIR}/cli/secrets.txt";
  };

  environment.systemPackages = [
    pkgs-unstable.ente-web
    pkgs-unstable.ente-cli
  ];
}
