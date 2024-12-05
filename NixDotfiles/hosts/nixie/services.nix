{ ... }: {
  imports = map (it: ../../services/${it}) [
    # System
    "Nginx.nix"
#    "Backup.nix"
#    "Monitoring"
#    "Wireguard.nix"
#
#    # Core Services
#    "Keycloak.nix"
#    "Nextcloud.nix"
#    "HedgeDoc.nix"
#    "Wiki-js.nix"
#
#    # Emily
#    "Syncthing.nix"
#    "YouTrack.nix"
#    "Tandoor.nix"
#    "Get.nix"
#
#    "PhotoManagement/PhotoPrism.nix"
#    "PhotoManagement/Piwigo.nix"
#    "PhotoManagement/Ente.nix"
  ];

  keycloak-setup.realm = "Emily-Realm";
}
