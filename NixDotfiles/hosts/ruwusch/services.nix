{ ... }: {
  imports = map (it: ../../services/${it}) [
    # System
    "Nginx.nix"
    "Backup.nix"
    "Wireguard.nix"

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
      transmission.enableExporter = false;

      keycloak = {
        realm = "Super-Realm";
        subdomain = "kc";
      };
    };
  };
}
