{ ... }: {
  imports = map (it: ../../services/${it}) [
    # System
    "Nginx.nix"
    "Backup.nix"

    # Core Services
    "Monitoring"
    "Syncthing.nix"
    "Keycloak.nix"
    "Nextcloud.nix"
    "HedgeDoc.nix"
    "Wiki-js.nix"
    "YouTrack.nix"
    "Get.nix"

    # Ruwusch but hosted on SSD
    "Stirling-PDF.nix"
    "Tandoor.nix"

    "PhotoManagement/Ente.nix"
#    "PhotoManagement/PhotoPrism.nix"
#    "PhotoManagement/Piwigo.nix"
  ];

  config = {
    host.services = {
      syncthing.enableExporter = false;

      nextcloud.enableExporter = false;
      nextcloud.subdomain = "wolke";

      ente.enableExporter = false;

      hedgedoc.subdomain = "emily-pad";

      keycloak = {
        realm = "Emily-Realm";
        subdomain = "auth";
      };
    };


    hardware.raid.HPSmartArray.enable = true;
  };

}
