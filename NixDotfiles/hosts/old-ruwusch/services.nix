{ ... }: {
  imports = map (it: ../../services/${it}) [
    # System
    "Nginx.nix"
    "Backup/Postgres.nix"

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

      syncthing = {
        subdomain = "old-sync";
        enableExporter = false;
      };

      keycloak = {
        realm = "Super-Realm";
        subdomain = "kc";
      };
    };
  };
}
