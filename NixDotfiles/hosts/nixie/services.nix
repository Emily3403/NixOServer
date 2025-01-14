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
      restic = {
        backup-host = "mar-restic.inet.tu-berlin.de";  # TODO
        enableExporter = false;
        repoName = "emily-nixie";
      };

      ente.enableExporter = false;

      nextcloud.subdomain = "wolke";
      hedgedoc.subdomain = "emily-pad";
      keycloak.realm = "Emily-Realm";
    };


    hardware.raid.HPSmartArray.enable = true;
  };

}
