{ ... }: {
  imports = map (it: ../../services/${it}) [
    # System
    "Nginx.nix"
    "Backup/Postgres.nix"

    # For Benchmarking...
    "Syncthing.nix"

#        "Transmission.nix"
        "Jellyfin.nix"

        "Keycloak.nix"
        "Nextcloud.nix"
  ];

  config = {
    host.services = {
      syncthing = {
        subdomain = "old-sync";
        enableExporter = false;
      };

      #      transmission = {
      #        subdomain = "old-transui";
      #      };

            jellyfin = {
              subdomain = "old-kino";
              enableExporter = false;
            };

      #      keycloak = {
      #        subdomain = "old-kc";
      #        realm = "Super-Realm";
      #      };

      #      nextcloud = {
      #        subdomain = "old-cloud";
      #        enableExporter = false;
      #      };
    };
  };
}
