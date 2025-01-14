let
  nixie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDl1EuW3ahRjtYzafPWux9fQqqblfq3TmNS62dwX2Xcz root@nixie";
  ruwusch = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJwG99nxyrMgSpHEgtexFQ96w5VaNf2zgR7Hm1bFHsMe root@ruwusch";
  old-ruwusch = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlF4l8I+lbs3JxYRfnkULPhV+svAtoDAr0CtpjR6Rtj root@old-ruwusch";
in
{

  # Nixie
  "nixie/Keycloak.age".publicKeys = [ nixie ];
  "nixie/HedgeDoc.age".publicKeys = [ nixie ];
  "nixie/Wiki-js.age".publicKeys = [ nixie ];
  "nixie/Tandoor.age".publicKeys = [ nixie ];
  "nixie/Stirling-PDF.age".publicKeys = [ nixie ];

  "nixie/Nextcloud/admin-password.age".publicKeys = [ nixie ];
  "nixie/Nextcloud/keycloak-client-secret.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Exporters/Nextcloud-token.age".publicKeys = [ nixie ];

  "nixie/Ente/Minio.age".publicKeys = [ nixie ];
  "nixie/Ente/Postgres.age".publicKeys = [ nixie ];

  "nixie/Restic/password.age".publicKeys = [ nixie ];
  "nixie/Restic/env.age".publicKeys = [ nixie ];

#  "nixie/.age".publicKeys = [ nixie ];
#  "nixie/.age".publicKeys = [ nixie ];
#  "nixie/.age".publicKeys = [ nixie ];
#  "nixie/.age".publicKeys = [ nixie ];
#  "nixie/.age".publicKeys = [ nixie ];
#  "nixie/.age".publicKeys = [ nixie ];

  "nixie/Monitoring/Grafana-admin-pw.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Grafana-secret-key.age".publicKeys = [ nixie ];

  "nixie/Monitoring/Access/nixie.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Access/ruwusch.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Access/Syncthing.age".publicKeys = [ nixie ];

  # Per-host htpasswd files
  "nixie/Monitoring/Nginx/nixie.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Nginx/ruwusch.age".publicKeys = [ ruwusch ];






  # Ruwusch
  "ruwusch/Keycloak.age".publicKeys = [ old-ruwusch ];
  "ruwusch/HedgeDoc.age".publicKeys = [ old-ruwusch ];


  "ruwusch/Wireguard.age".publicKeys = [ old-ruwusch ];
  "ruwusch/Transmission.age".publicKeys = [ old-ruwusch ];
  "nixie/Monitoring/Exporters/Transmission.age".publicKeys = [ old-ruwusch ];

  "ruwusch/Nextcloud/admin-password.age".publicKeys = [ old-ruwusch ];
  "ruwusch/Nextcloud/keycloak-client-secret.age".publicKeys = [ old-ruwusch ];
  #  "ruwusch/.age".publicKeys = [ old-ruwusch ];
  #  "ruwusch/.age".publicKeys = [ old-ruwusch ];
  #  "ruwusch/.age".publicKeys = [ old-ruwusch ];



  # Shared


  "Keycloak/DatabasePassword.age".publicKeys = [ old-ruwusch ];
  "Keycloak/AdminPassword.age".publicKeys = [ old-ruwusch ];

  "Nextcloud/AdminPassword.age".publicKeys = [ old-ruwusch ];
  "Nextcloud/KeycloakClientSecret.age".publicKeys = [ old-ruwusch ];

  "Affine/Environment.age".publicKeys = [ old-ruwusch ];
  "Affine/Postgres.age".publicKeys = [ old-ruwusch ];
  "Affine/Redis.age".publicKeys = [ old-ruwusch ];

  "Ente/Env.age".publicKeys = [ old-ruwusch ];
  "Ente/Postgres.age".publicKeys = [ old-ruwusch ];
  "Ente/Minio.age".publicKeys = [ old-ruwusch ];

  "HedgeDoc.age".publicKeys = [ old-ruwusch ];
  "Transmission.age".publicKeys = [ old-ruwusch ];
  "ATransmission.age".publicKeys = [ old-ruwusch ];
  "Luk-Docs.age".publicKeys = [ old-ruwusch ];
  "Wireguard.age".publicKeys = [ old-ruwusch ];
  "PhotoPrism.age".publicKeys = [ old-ruwusch ];
  "Tandoor.age".publicKeys = [ old-ruwusch ];
  "Piwigo-Mariadb.age".publicKeys = [ old-ruwusch ];

  "SSHKeys/wiki-js.age".publicKeys = [ old-ruwusch ];

  "Monitoring/Grafana/admin-pw.age".publicKeys = [ old-ruwusch ];
  "Monitoring/Grafana/secret-key.age".publicKeys = [ old-ruwusch ];

  "Monitoring/Prometheus/ruwusch-pw.age".publicKeys = [ old-ruwusch ];
  "Monitoring/Nginx/ruwusch-htpasswd.age".publicKeys = [ old-ruwusch ];

  "Monitoring/Exporters/Transmission.age".publicKeys = [ old-ruwusch ];
  "Monitoring/Exporters/Syncthing.age".publicKeys = [ old-ruwusch ];
  "Monitoring/Exporters/Syncthing-API-Key.age".publicKeys = [ old-ruwusch ];
  "Monitoring/Exporters/Nextcloud-Token.age".publicKeys = [ old-ruwusch ];
  "Monitoring/Exporters/PhotoPrism-Token.age".publicKeys = [ old-ruwusch ];
}
