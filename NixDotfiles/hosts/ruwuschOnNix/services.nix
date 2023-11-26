{...}: {
  imports = map (it: ../../services/${it}) [
    "Nginx.nix"
    "HedgeDoc.nix"
    "KeyCloak.nix"
    "Nextcloud.nix"
    "Wiki-js.nix"
    "YouTrack.nix"
    "Syncthing.nix"
    "Transmission.nix"
  ];

  keycloak-setup.realm = "Super-Realm";
}