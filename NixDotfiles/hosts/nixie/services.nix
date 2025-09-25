{ ... }: {
  imports = map (it: ../../services/${it}) [
    # System
    "Nginx.nix"
    "Backup/Restic-Client.nix"

    # Core Services
    "Monitoring"
    "Syncthing.nix"
    "Keycloak.nix"
    "Nextcloud.nix"
    "HedgeDoc.nix"
    "Get.nix"
    "Wiki-js.nix"
    "YouTrack.nix"
    "Firefly-III.nix"

    # Ruwusch but hosted on SSD
    "Stirling-PDF.nix"
    "Tandoor.nix"

    "Archiving"
    "Photo-Management"
  ];

  config = {
    host.services = {
      restic.enableExporter = false;
      ente.enableExporter = false;

      nextcloud.subdomain = "wolke";
      hedgedoc.subdomain = "emily-pad";
      keycloak.realm = "Emily-Realm";
    };


    hardware.raid.HPSmartArray.enable = true;
  };

}
