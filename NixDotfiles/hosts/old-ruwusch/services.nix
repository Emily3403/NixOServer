{ ... }: {
  imports = map (it: ../../services/${it}) [
    # System
    "Nginx.nix"
    "Backup/Postgres.nix"

    "Media/Transmission.nix"
    "Media/Jellyfin.nix"

    "Keycloak.nix"
    "Nextcloud.nix"

    "Syncthing.nix"
  ];

  config = {
    host.services = {
      syncthing = {
        subdomain = "old-sync";
        enableExporter = false;
      };

      transmission = {
        subdomain = "old-transui";
        enableExporter = true;
      };

      jellyfin = {
        subdomain = "old-kino";
        enableExporter = false;
      };

      keycloak = {
        subdomain = "old-kc";
        realm = "Super-Realm";
      };

      nextcloud = {
        subdomain = "old-cloud";
        enableExporter = false;
      };
    };
  };
}
