{ ... }: {
  imports = map (it: ../../services/${it}) [
    "Nginx.nix"
    "HedgeDoc.nix"
    "Keycloak.nix"
    "Nextcloud.nix"
    "Next.nix"
    "Wiki-js.nix"
    "YouTrack.nix"
    "Syncthing.nix"
    "Transmission.nix"
    "Jellyfin.nix"
    "Backup/Duplicati.nix"
    "Backup/UrBackup.nix"
    "Backup/Borg.nix"
    "Backup/Restic.nix"
    "Backup/Rsnapshot.nix"
  ];

  keycloak-setup.realm = "Super-Realm";
}
