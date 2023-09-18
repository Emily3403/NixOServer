{ pkgs, options, config, lib, ...}: {

  services.nginx.virtualHosts = {
    "nextcloud.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://192.168.7.103:80/";
    };
  };

  containers.nextcloud =
  let
    domainName = config.domainName;
    age = config.age;
  in
  {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.7.1";
    localAddress = "192.168.7.103";

    bindMounts = {
      "/var/lib/nextcloud" = {
        hostPath = "/data/nextcloud/nextcloud";
        isReadOnly = false;
      };

      "/var/lib/postgresql" = {
        hostPath = "/data/nextcloud/postgresql";
        isReadOnly = false;
      };

      "${age.secrets.NextcloudAdminPassword.path}" = { hostPath = age.secrets.NextcloudAdminPassword.path; };
      "${age.secrets.NexcloudKeycloakClientSecret.path}" = { hostPath = age.secrets.NexcloudKeycloakClientSecret.path; };
    };

    config = { pkgs, config, lib, ...}: {
      system.stateVersion = "23.05";
      documentation.man.generateCaches = false;
      networking.firewall.allowedTCPPorts = [ 80 ];

      users.users.nextcloud = {
        uid = 5002;
      };

      programs = {
        neovim = {
          enable = true;
          viAlias = true;
          vimAlias = true;
        };

        fish.enable = true;
      };
      users.users.root.shell = pkgs.fish;

      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud26;
        datadir = "/var/lib/nextcloud";
        hostName = "nextcloud.${domainName}";
        https = true;

        secretFile = age.secrets.NexcloudKeycloakClientSecret.path;

        config = {
          adminuser = "admin";
          adminpassFile = age.secrets.NextcloudAdminPassword.path;

          dbtype = "pgsql";
          dbhost = "/run/postgresql";
          dbuser = "nextcloud";
          dbname = "nextcloud";
          extraTrustedDomains = [ "192.168.7.1" ];

          defaultPhoneRegion = "DE";
        };

        # Configure the opcache module as recommended
        phpOptions = options.services.nextcloud.phpOptions.default // {
          "opcache.jit" = "tracing";
          "opcache.jit_buffer_size" = "100M";
          "opcache.interned_strings_buffer" = "16";
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
#          oidc = pkgs.fetchNextcloudApp rec {
#            url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v2.5.1/oidc_login.tar.gz";
#            sha256 = "sha256-lQaoKjPTh1RMXk2OE+ULRYKw70OCCFq1jKcUQ+c6XkA=";
#          };
        };

        extraOptions = {
          # Behaviour of OpenID Connect with Keycloak
          oidc_login_provider_url = "https://keycloak.${domainName}/realms/INET";
          oidc_login_logout_url = "https://nextcloud.${domainName}/apps/oidc_login/oidc";

          oidc_login_client_id = "Nextcloud";
    #      oidc_login_client_secret = ...  # Set via the `secretFile` attribute

          oidc_login_auto_redirect = true;  # TODO: Do we want to auto-redirect?
          oidc_login_end_session_redirect = true;
          oidc_login_use_id_token = false;
          oidc_login_tls_verify = true;
          oidc_login_scope = "openid profile";

          oidc_login_attributes = {
            id = "preferred_username";
            name = "preferred_username";
            mail = "email";
            quota = "ownCloudQuota";  # TODO: Does not exist
            home = "homeDirectory";  # TODO: Does not exist
            ldap_uid = "uid";
            groups = "groups";
            login_filter = "realm_access_roles";
            photoURL = "picture";
            is_admin = "ownCloudAdmin";
          };

          # Keycloak time settings
          oidc_login_public_key_caching_time = 86400;
          oidc_login_min_time_between_jwks_requests = 10;
          oidc_login_well_known_caching_time = 86400;


          # Appearence of OpenID Connect
          oidc_login_button_text = "Log in with OpenID";
          oidc_login_hide_password_form = false;

          # Nextcloud config
          allow_user_to_change_display_name = true;
          lost_password_link = "disabled";
          overwriteprotocol = "https";
          default_locale = "en_IE";

          oidc_login_default_quota = "107374182400";
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

        };

      };

      # Caching
      services.redis.servers."nextcloud" = {
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

      # Database
      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_15;

        ensureDatabases = [ "nextcloud" ];
        ensureUsers = [
          {
            name = "nextcloud";
            ensurePermissions = { "DATABASE nextcloud" = "ALL PRIVILEGES"; };
            ensureClauses = {
              superuser = true;
            };
          }
        ];
      };

      systemd.services."nextcloud-setup" = {
        requires = [ "postgresql.service" ];
        after = [ "postgresql.service"];
      };

    };

  };

  users.users.nextcloud = {
    isNormalUser = true;
    uid = 5002;
  };

  systemd.tmpfiles.rules = [
    "d /data/nextcloud/nextcloud 0755 nextcloud"
    "d /data/nextcloud/postgresql 0755 nextcloud"
  ];
}