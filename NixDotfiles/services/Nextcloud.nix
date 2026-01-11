{ pkgs, config, inputs, options, lib, ... }:
let
  inherit (lib) mkIf mkOption types;
  utils = import ../utils.nix { inherit config lib; };

  ncfg = config.host.services.nextcloud;
  kcfg = config.host.services.keycloak;

  containerID = 3;

  nginxConfig = ''
    client_body_buffer_size 400M;
    proxy_max_temp_file_size 10024m;
    fastcgi_read_timeout 3600s;
    fastcgi_send_timeout 3600s;
    fastcgi_connect_timeout 3600s;
    proxy_read_timeout 3600s;
  '';
in
{
  options.host.services.nextcloud = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Nextcloud";
    };

    subdomain = mkOption {
      type = types.str;
      default = "cloud";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${ncfg.dataDir} 0750 nextcloud"
      "d ${ncfg.dataDir}/nextcloud 0750 nextcloud"
      "d ${ncfg.dataDir}/postgresql 0750 postgres"
    ];

    age.secrets.Nextcloud_admin-password = {
      file = ../secrets/${config.host.name}/Nextcloud/admin-password.age;
      owner = "nextcloud";
    };

    age.secrets.Nextcloud_keycloak = {
      file = ../secrets/${config.host.name}/Nextcloud/keycloak.age;
      owner = "nextcloud";
    };

    age.secrets.Nextcloud_exporter-tokenfile = mkIf ncfg.enableExporter {
      file = ../secrets/nixie/Monitoring/Exporters/${config.host.name}/Nextcloud.age;
      owner = "995";
    };

    services.nginx.virtualHosts."${config.host.networking.monitoringDomain}" = mkIf ncfg.enableExporter (utils.makeNginxMetricConfig "nextcloud" (utils.makeNixContainerIP containerID) "9205");
  };

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config inputs lib pkgs containerID;
        subdomain = ncfg.subdomain;

        name = "nextcloud";
        containerPort = 80;
        isSystemUser = true;

        postgresqlName = "nextcloud";
        additionalNginxConfig.extraConfig = "client_max_body_size 200G;" + nginxConfig;

        bindMounts = {
          "/var/lib/nextcloud" = { hostPath = "${ncfg.dataDir}/nextcloud"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${ncfg.dataDir}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.Nextcloud_admin-password.path}".hostPath = config.age.secrets.Nextcloud_admin-password.path;
          "${config.age.secrets.Nextcloud_keycloak.path}".hostPath = config.age.secrets.Nextcloud_keycloak.path;
        } // lib.optionalAttrs ncfg.enableExporter {
          "${config.age.secrets.Nextcloud_exporter-tokenfile.path}".hostPath = config.age.secrets.Nextcloud_exporter-tokenfile.path;
        };

        cfg = {
          services.nginx.virtualHosts."${ncfg.subdomain}.${config.host.networking.domainName}".extraConfig = nginxConfig;

          services.nextcloud = {
            enable = true;
            package = pkgs.nextcloud31;
            hostName = "${ncfg.subdomain}.${config.host.networking.domainName}";
            https = true;
            maxUploadSize = "200G";
            secretFile = config.age.secrets.Nextcloud_keycloak.path;

            config = {
              adminuser = "admin";
              adminpassFile = config.age.secrets.Nextcloud_admin-password.path;

              dbtype = "pgsql";
              dbhost = "/run/postgresql";
              dbuser = "nextcloud";
              dbname = "nextcloud";
            };

            poolSettings = {
              pm = "dynamic";
              "pm.max_children" = "200";
              "pm.max_requests" = "500";
              "pm.max_spare_servers" = "24";
              "pm.min_spare_servers" = "6";
              "pm.start_servers" = "24";
            };

            # Configure the opcache module as recommended
            phpOptions = {
              "opcache.jit" = "tracing";
              "opcache.jit_buffer_size" = "100M";
              "opcache.interned_strings_buffer" = "16";
              "opcache.max_accelerated_files" = "10000";
              "opcache.memory_consumption" = "1280";
            };

            caching.redis = true;
            configureRedis = true;

            # App config
            appstoreEnable = true;
            extraAppsEnable = true;

            autoUpdateApps.enable = false;
            autoUpdateApps.startAt = "05:00:00";

            extraApps = {
              inherit (pkgs.nextcloud31Packages.apps)
                calendar
                contacts
#                files_markdown  # Not supported: https://github.com/icewind1991/files_markdown/issues/218
                groupfolders
                # phonetrack  # TODO: Look into this
                onlyoffice
                ;

              oidc_login = pkgs.fetchNextcloudApp rec {
                url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v3.2.0/oidc_login.tar.gz";
                sha256 = "141xkbvrwmhgmcicpd9g86jmhihqrp50ijmhgl4n9ksc8cldmdhf"; # get this with `nix-prefetch-url {url}`
                license = "agpl3Only";
              };
            };

            settings = {
              log_type = "file";
              loglevel = 1;
              overwriteprotocol = "https";
              default_phone_region = "DE";
              trusted_proxies = [ config.host.networking.containerHostIP ];

              # Behaviour of OpenID Connect with Keycloak
              oidc_login_provider_url = "https://${kcfg.subdomain}.${kcfg.domain}/realms/${kcfg.realm}";
              oidc_login_logout_url = "https://${ncfg.subdomain}.${config.host.networking.domainName}/apps/oidc_login/oidc";
              oidc_login_client_id = "Nextcloud";

              oidc_login_auto_redirect = true;
              oidc_login_end_session_redirect = true;
              oidc_login_use_id_token = false;
              oidc_login_tls_verify = true;
              oidc_login_scope = "openid profile";

              oidc_login_attributes = {
                id = "preferred_username";
                name = "name";
                mail = "email";
                ldap_uid = "uid";
                groups = "groups";
                login_filter = "realm_access_roles";
                photoURL = "picture";
              };

              # Keycloak time settings
              oidc_login_public_key_caching_time = 86400;
              oidc_login_min_time_between_jwks_requests = 10;
              oidc_login_well_known_caching_time = 86400;

              # Appearence of OpenID Connect
              oidc_login_button_text = "Log in with Keycloak";
              oidc_login_hide_password_form = false;

              # Nextcloud config
              allow_user_to_change_display_name = true;
              lost_password_link = "disabled";
              default_locale = "en_IE";
              upgrade.disable-web = false;

              oidc_login_default_group = "Authenticated";
              oidc_login_disable_registration = false;
              oidc_create_groups = true;
              oidc_login_webdav_enabled = true;
              oidc_login_password_authentication = false;

              # Max File size limit
              chunk_size = "512MB";
              max_input_time = "3600";
              max_execution_time = "3600";
              output_buffering = "0";

              # Calendar
              calendarSubscriptionRefreshRate = "PT1H";
              maintenance_window_start = "1";
            };
          };

          systemd.services."nextcloud-setup" = {
            requires = [ "postgresql.service" ];
            after = [ "postgresql.service" ];
          };

          services.prometheus.exporters.nextcloud = mkIf ncfg.enableExporter {
            enable = true;
            url = "https://${ncfg.subdomain}.${config.host.networking.domainName}";
            tokenFile = config.age.secrets.Nextcloud_exporter-tokenfile.path;
            openFirewall = true;
          };
        };
      }
    )
  ];
}
