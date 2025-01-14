{ ... }: {
  imports = map (it: ../../services/${it}) [
    # System
    "Nginx.nix"
    "Backup/Restic-Client.nix"

    "WireGuard.nix"
    "Media"

    # Carsten
    "Keycloak.nix"
    "Nextcloud.nix"
    "HedgeDoc.nix"
  ];

  config = {
    host.services = {
      restic.enableExporter = false;

      keycloak = {
        realm = "Super-Realm";
        subdomain = "kc";
      };
    };
  };
}
