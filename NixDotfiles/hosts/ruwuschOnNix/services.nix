{ ... }: {
  imports = map (it: ../../services/${it}) [
    "Nginx.nix"
    "HedgeDoc.nix"
    "KeyCloak.nix"
    "Nextcloud.nix"
    "Wiki-js.nix"
    "YouTrack.nix"
    "Syncthing.nix"
    "Transmission.nix"
    "Backup/Duplicati.nix"
    "Backup/UrBackup.nix"
    "Backup/Borg.nix"
    "Backup/Restic.nix"
    "Backup/Rsnapshot.nix"
  ];

  keycloak-setup.realm = "Super-Realm";
}
