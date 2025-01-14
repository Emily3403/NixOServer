{ ... }: {
  imports = map (it: ../../services/${it}) [
    # System
    "Nginx.nix"
#    "Backup/Restic-Client.nix"

    "WireGuard.nix"
    "Media"

    # Carsten
    "Keycloak.nix"
    "Nextcloud.nix"
    "HedgeDoc.nix"
  ];

  config = {
    host.services = {
#      restic = {
#        backup-host = "mar-restic.inet.tu-berlin.de";  # TODO
#        enableExporter = false;
#        repoName = "ruwusch";
#      };

      keycloak = {
        realm = "Super-Realm";
        subdomain = "kc";
      };
    };
  };
}
