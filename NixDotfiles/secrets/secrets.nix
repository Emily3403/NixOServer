let
  nixie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDl1EuW3ahRjtYzafPWux9fQqqblfq3TmNS62dwX2Xcz root@nixie";
  ruwusch = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJwG99nxyrMgSpHEgtexFQ96w5VaNf2zgR7Hm1bFHsMe root@ruwusch";
  old-ruwusch = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlF4l8I+lbs3JxYRfnkULPhV+svAtoDAr0CtpjR6Rtj root@old-ruwusch";
in
{
  # == Nixie
  "nixie/HedgeDoc.age".publicKeys = [ nixie ];
  "nixie/Keycloak.age".publicKeys = [ nixie ];
  "nixie/Stirling-PDF.age".publicKeys = [ nixie ];
  "nixie/Tandoor.age".publicKeys = [ nixie ];
  "nixie/Wiki-js.age".publicKeys = [ nixie ];

  "nixie/Nextcloud/admin-password.age".publicKeys = [ nixie ];
  "nixie/Nextcloud/keycloak-client-secret.age".publicKeys = [ nixie ];

  "nixie/Ente/Minio.age".publicKeys = [ nixie ];
  "nixie/Ente/Postgres.age".publicKeys = [ nixie ];

  "nixie/Restic/password.age".publicKeys = [ nixie ];
  "nixie/Restic/env.age".publicKeys = [ nixie ];

  ## Monitoring
  "nixie/Monitoring/Grafana-admin-pw.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Grafana-secret-key.age".publicKeys = [ nixie ];

  # Access to the metrics
  "nixie/Monitoring/Access/nixie.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Access/ruwusch.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Access/old-ruwusch.age".publicKeys = [ nixie ];

  "nixie/Monitoring/Access/Syncthing.age".publicKeys = [ nixie ];

  "nixie/Monitoring/Exporters/Syncthing.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Exporters/Nextcloud-token.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Exporters/Transmission.age".publicKeys = [ ruwusch ];
  "nixie/Monitoring/Exporters/Old-Transmission.age".publicKeys = [ old-ruwusch ];

  # Per-host htpasswd files
  "nixie/Monitoring/Nginx/nixie.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Nginx/ruwusch.age".publicKeys = [ ruwusch ];
  "nixie/Monitoring/Nginx/old-ruwusch.age".publicKeys = [ old-ruwusch ];


  # == Ruwusch
  "ruwusch/Keycloak.age".publicKeys = [ ruwusch ];
  "ruwusch/HedgeDoc.age".publicKeys = [ ruwusch ];

  "ruwusch/Wireguard.age".publicKeys = [ ruwusch ];
  "ruwusch/Transmission.age".publicKeys = [ ruwusch ];

  "ruwusch/Nextcloud/admin-password.age".publicKeys = [ ruwusch ];
  "ruwusch/Nextcloud/keycloak-client-secret.age".publicKeys = [ ruwusch ];

  "old-ruwusch/Transmission.age".publicKeys = [ old-ruwusch ];
  "old-ruwusch/Keycloak.age".publicKeys = [ old-ruwusch ];
  "old-ruwusch/Nextcloud/admin-password.age".publicKeys = [ old-ruwusch ];
  "old-ruwusch/Nextcloud/keycloak-client-secret.age".publicKeys = [ old-ruwusch ];


  # == Legacy
  "ATransmission.age".publicKeys = [ old-ruwusch ];

  "Affine/Environment.age".publicKeys = [ old-ruwusch ];
  "Affine/Postgres.age".publicKeys = [ old-ruwusch ];
  "Affine/Redis.age".publicKeys = [ old-ruwusch ];

  "PhotoPrism.age".publicKeys = [ old-ruwusch ];
  "Piwigo-Mariadb.age".publicKeys = [ old-ruwusch ];

  "Monitoring/Exporters/Nextcloud-Token.age".publicKeys = [ old-ruwusch ];
  "Monitoring/Exporters/PhotoPrism-Token.age".publicKeys = [ old-ruwusch ];
  "Monitoring/Exporters/Syncthing.age".publicKeys = [ old-ruwusch ];
}
