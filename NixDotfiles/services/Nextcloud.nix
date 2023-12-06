let

  SUBDOMAIN = "cloud";
  CONTAINER_IP = "192.168.7.111";
  CONTAINER_PORT = 80;
  DATA_DIR = "/data/Nextcloud";

  KEYCLOAK_CLIENT = "Nextcloud";

in

{ pkgs, options, config, lib, ... }: {

  imports = [ ../users/services/nextcloud.nix ];

  services.nginx.virtualHosts = {
    "${SUBDOMAIN}.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://${CONTAINER_IP}:${toString CONTAINER_PORT}/";
      extraConfig = ''
        client_max_body_size 200G;
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/nextcloud 0755 nextcloud"
    "d ${DATA_DIR}/postgresql 0755 nextcloud"
  ];

  containers.nextcloud = let cfg = config; in {
    autoStart = true;
    privateNetwork = true;
    hostAddress = config.containerHostIP;
    localAddress = CONTAINER_IP;

    bindMounts = {
      "/var/lib/nextcloud" = { hostPath = "${DATA_DIR}/nextcloud"; isReadOnly = false; };
      "/var/lib/postgresql" = { hostPath = "${DATA_DIR}/postgresql"; isReadOnly = false; };
      "/var/lib/syncthing" = { hostPath = "/data/Syncthing/syncthing/"; isReadOnly = false; };
      "${cfg.age.secrets.Nextcloud_AdminPassword.path}".hostPath = cfg.age.secrets.Nextcloud_AdminPassword.path;
      "${cfg.age.secrets.Nexcloud_KeycloakClientSecret.path}".hostPath = cfg.age.secrets.Nexcloud_KeycloakClientSecret.path;
    };

    config = { pkgs, config, lib, ... }: {
      networking.firewall.allowedTCPPorts = [ CONTAINER_PORT ];
      imports = [
        ../users/root.nix
        ../users/services/nextcloud.nix
        ../system.nix
        (import ./Container-Config/Postgresql.nix { dbName = "nextcloud"; dbUser = "nextcloud"; pkgs = pkgs; })
      ];

      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud27;
        datadir = "/var/lib/nextcloud";
        hostName = "${SUBDOMAIN}.${cfg.domainName}";
        https = true;

        secretFile = cfg.age.secrets.Nexcloud_KeycloakClientSecret.path;

        config = {
          adminuser = "admin";
          adminpassFile = cfg.age.secrets.Nextcloud_AdminPassword.path;

          dbtype = "pgsql";
          dbhost = "/run/postgresql";
          dbuser = "nextcloud";
          dbname = "nextcloud";
          extraTrustedDomains = [ cfg.containerHostIP ];

          defaultPhoneRegion = "DE";
        };

        # Configure the opcache module as recommended
        phpOptions = options.services.nextcloud.phpOptions.default // {
          # Tune Nextcloud
          "pm" = "dynamic";
          "pm.max_children" = "200";
          "pm.start_servers" = "32";
          "pm.min_spare_servers" = "6";
          "pm.max_spare_servers" = "24";

          # Tune OPCache
          "opcache.jit" = "tracing";
          "opcache.jit_buffer_size" = "100M";
          "opcache.interned_strings_buffer" = "16";
          "opcache.max_accelerated_files" = "10000";
          "opcache.memory_consumption" = "1280";
        };

        caching.redis = true;

        # App config
        appstoreEnable = true;
        extraAppsEnable = true;

        autoUpdateApps.enable = true;
        autoUpdateApps.startAt = "05:00:00";

        extraApps = {
          inherit (pkgs.nextcloud26Packages.apps)
            calendar
            files_markdown
            groupfolders
            polls
            deck
            onlyoffice
            ;

          oidc = pkgs.fetchNextcloudApp rec {
            url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v2.5.1/oidc_login.tar.gz";
            sha256 = "sha256-lQaoKjPTh1RMXk2OE+ULRYKw70OCCFq1jKcUQ+c6XkA=";
          };
        };

        extraOptions = {
          # Behaviour of OpenID Connect with Keycloak
          oidc_login_provider_url = "https://${cfg.keycloak-setup.subdomain}.${cfg.keycloak-setup.domain}/realms/${cfg.keycloak-setup.realm}";
          oidc_login_logout_url = "https://${SUBDOMAIN}.${cfg.domainName}/apps/oidc_login/oidc";

          oidc_login_client_id = KEYCLOAK_CLIENT;
          #      oidc_login_client_secret = ...  # Set via the `secretFile` attribute

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
          overwriteprotocol = "https";
          default_locale = "en_IE";

          oidc_login_default_group = "Authenticated";
          oidc_login_disable_registration = false;
          oidc_create_groups = true;
          oidc_login_webdav_enabled = true;
          oidc_login_password_authentication = false;

          # Defaults to acknowledge I have understood them
          oidc_login_use_external_storage = false;
          oidc_login_proxy_ldap = false;
          oidc_login_redir_fallback = false;
          oidc_login_update_avatar = false;
          oidc_login_skip_proxy = false;

          # Calendar
          calendarSubscriptionRefreshRate = "PT1H";

          # Max File size limit
          upload_max_filesize = "200G";
          post_max_size = "200G";

        };

      };

      # Caching
      services.redis.servers."${SUBDOMAIN}" = {
        enable = true;
        bind = "::1";
        port = 6379;
      };

      systemd.services.nextcloud-setup.serviceConfig.ExecStartPost = pkgs.writeScript "nextcloud-redis.sh" ''
        #!${pkgs.runtimeShell}
        nextcloud-occ config:system:set redis 'host' --value '::1' --type string
        nextcloud-occ config:system:set redis 'port' --value 6379 --type integer
        nextcloud-occ config:system:set memcache.local --value '\OC\Memcache\Redis' --type string
        nextcloud-occ config:system:set memcache.locking --value '\OC\Memcache\Redis' --type string
      '';

      systemd.services."nextcloud-setup" = {
        requires = [ "postgresql.service" ];
        after = [ "postgresql.service" ];
      };

    };

  };
}
