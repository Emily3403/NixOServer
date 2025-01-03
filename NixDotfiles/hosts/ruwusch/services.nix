{ ... }: {
  imports = map (it: ../../services/${it}) [
    # System
    "Nginx.nix"
    "Backup.nix"
#    "Monitoring"
    "Wireguard.nix"

    # Core Services
    "Transmission.nix"
    "Jellyfin.nix"

    # Carsten
    "Keycloak.nix"
    "Nextcloud.nix"
    "HedgeDoc.nix"
  ];

  host.services.keycloak.realm = "Super-Realm";
}
