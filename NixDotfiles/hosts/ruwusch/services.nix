{ ... }: {
  imports = map (it: ../../services/${it}) [
    "Nginx.nix"
    "HedgeDoc.nix"
    "Keycloak.nix"
    "Nextcloud.nix"
    "Wiki-js.nix"
    "YouTrack.nix"
    "Syncthing.nix"
    "Transmission.nix"
    "Jellyfin.nix"
    "Luk-Docs.nix"
    "Backup.nix"
#    "Wireguard.nix"
  ];

  keycloak-setup.realm = "Super-Realm";
}
