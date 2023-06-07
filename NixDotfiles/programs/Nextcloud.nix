{ pkgs, config, lib, ...}: {
    services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud26;
        datadir = "/database/nextcloud";
        hostName = "nextcloud.uwu.com";

        config = {
          adminuser = "admin";
          adminpassFile = config.age.secrets.NextcloudAdminPassword.path;

          dbhost = "/run/postgresql";
          dbtype = "pgsql";
          dbuser = "nextcloud";
          dbname = "nextcloud";
        };


        # App config
        extraApps = {
            inherit (pkgs.nextcloud26Packages.apps)
            calendar
            files_markdown
            groupfolders
            polls
            deck
            onlyoffice
            ;

#            oidc = pkgs.fetchNextcloudApp rec {
#              url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v2.5.1/oidc_login.tar.gz";
#              sha256 = "sha256-lQaoKjPTh1RMXk2OE+ULRYKw70OCCFq1jKcUQ+c6XkA=";
#            };

        };

        appstoreEnable = true;
        extraAppsEnable = true;
        autoUpdateApps.enable = true;

        # Set what time makes sense for you
        autoUpdateApps.startAt = "05:00:00";


        # TODO: Redis Caching?
    };

    services.postgresql = {
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [
        {
          name = "nextcloud";
          ensurePermissions = { "DATABASE nextcloud" = "ALL PRIVILEGES"; };
        }
      ];
    };
}