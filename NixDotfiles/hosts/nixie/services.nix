{ ... }: {
  imports = map (it: ../../services/${it}) [
    # System
    "Nginx.nix"
    "Backup.nix"
#    "Monitoring"

#    # Core Services
    "Keycloak.nix"
    "Nextcloud.nix"
    "HedgeDoc.nix"
    "Wiki-js.nix"

    "Syncthing.nix"
    "YouTrack.nix"
    "Tandoor.nix"
    "Get.nix"

#    "PhotoManagement/PhotoPrism.nix"
#    "PhotoManagement/Piwigo.nix"
    "PhotoManagement/Ente.nix"
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
