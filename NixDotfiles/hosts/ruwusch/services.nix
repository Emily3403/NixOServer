{ ... }: {
  imports = map (it: ../../services/${it}) [
    # System
    "Nginx.nix"
    "Backup/Postgres.nix"
    "Wireguard.nix"
    "Syncthing.nix"

    # Core Services
    "Transmission.nix"
    "Jellyfin.nix"

    # Carsten
    "Keycloak.nix"
    "Nextcloud.nix"
    "HedgeDoc.nix"
  ];

  config = {
    host.services = {
      nextcloud.enableExporter = false;

      syncthing.subdomain = "other-sync";
      syncthing.enableExporter = false;

      keycloak = {
        realm = "Super-Realm";
        subdomain = "kc";
      };
    };
  };
}
