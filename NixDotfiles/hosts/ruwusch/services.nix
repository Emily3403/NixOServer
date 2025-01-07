{ ... }: {
  imports = map (it: ../../services/${it}) [
    # System
    "Nginx.nix"
#    "Backup.nix"
#    "Monitoring"
#    "Wireguard.nix"

    # Core Services
#    "Transmission.nix"
#    "Jellyfin.nix"

    # Emily
#    "Tandoor.nix"
#    "Stirling-PDF.nix"
  ];

  keycloak-setup.realm = "Super-Realm";
}
