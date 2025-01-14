{ ... }: {
  imports = map (it: ../../services/${it}) [
    # System
    "Nginx.nix"
    "Backup/Postgres.nix"

    # Core Services
    "Wireguard.nix"
    "Media"

    # Carsten
    "Keycloak.nix"
    "Nextcloud.nix"
    "HedgeDoc.nix"

    # Temp Benchmarking
    "Syncthing.nix"
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
