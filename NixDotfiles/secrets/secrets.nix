let
  nixie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDl1EuW3ahRjtYzafPWux9fQqqblfq3TmNS62dwX2Xcz root@nixie";
  ruwusch = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlF4l8I+lbs3JxYRfnkULPhV+svAtoDAr0CtpjR6Rtj root@ruwusch";
in
{
  # == nixie
  "nixie/HedgeDoc.age".publicKeys = [ nixie ];
  "nixie/Keycloak.age".publicKeys = [ nixie ];
  "nixie/Stirling-PDF.age".publicKeys = [ nixie ];
  "nixie/Tandoor.age".publicKeys = [ nixie ];
  "nixie/Wiki-js.age".publicKeys = [ nixie ];

  "nixie/Nextcloud/admin-password.age".publicKeys = [ nixie ];
  "nixie/Nextcloud/keycloak-client-secret.age".publicKeys = [ nixie ];

  "nixie/Firefly-III/app-key.age".publicKeys = [ nixie ];
  "nixie/Firefly-III/access-token.age".publicKeys = [ nixie ];

  "nixie/Photo-Management/Ente/Minio.age".publicKeys = [ nixie ];
  "nixie/Photo-Management/Ente/Postgres.age".publicKeys = [ nixie ];
  "nixie/Photo-Management/Lychee/Env.age".publicKeys = [ nixie ];
  "nixie/Photo-Management/Lychee/Postgres.age".publicKeys = [ nixie ];
  "nixie/Photo-Management/PhotoPrism.age".publicKeys = [ nixie ];


  "nixie/Restic/password.age".publicKeys = [ nixie ];
  "nixie/Restic/env.age".publicKeys = [ nixie ];

  ## Monitoring
  "nixie/Monitoring/Grafana/admin-pw.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Grafana/secret-key.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Grafana/keycloak.age".publicKeys = [ nixie ];

  ### Per-host htpasswd files
  "nixie/Monitoring/Nginx/nixie.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Nginx/ruwusch.age".publicKeys = [ ruwusch ];

  ### Access to the metrics of each host
  "nixie/Monitoring/Access/nixie.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Access/ruwusch.age".publicKeys = [ nixie ];

  #### Additional Access tokens
  "nixie/Monitoring/Access/nixie/Syncthing.age".publicKeys = [ nixie ];

  ### Exporters
  "nixie/Monitoring/Exporters/nixie/Syncthing.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Exporters/nixie/Nextcloud.age".publicKeys = [ nixie ];

  "nixie/Monitoring/Exporters/ruwusch/Nextcloud.age".publicKeys = [ ruwusch ];
  "nixie/Monitoring/Exporters/ruwusch/Transmission.age".publicKeys = [ ruwusch ];
  "nixie/Monitoring/Exporters/ruwusch/Jellyfin.age".publicKeys = [ ruwusch ];
  "nixie/Monitoring/Exporters/ruwusch/Jellyseer.age".publicKeys = [ ruwusch ];


  # == ruwusch
  "ruwusch/Keycloak.age".publicKeys = [ ruwusch ];
  "ruwusch/HedgeDoc.age".publicKeys = [ ruwusch ];
  "ruwusch/WireGuard.age".publicKeys = [ ruwusch ];
  "ruwusch/Transmission.age".publicKeys = [ ruwusch ];
  "ruwusch/Other-Transmission.age".publicKeys = [ ruwusch ];

  "ruwusch/Nextcloud/admin-password.age".publicKeys = [ ruwusch ];
  "ruwusch/Nextcloud/keycloak-client-secret.age".publicKeys = [ ruwusch ];

  "ruwusch/Restic/password.age".publicKeys = [ ruwusch ];
  "ruwusch/Restic/env.age".publicKeys = [ ruwusch ];

  "ruwusch/VPN/Headscale.age".publicKeys = [ ruwusch ];


  # == Legacy
  "ATransmission.age".publicKeys = [ ruwusch ];

  "Affine/Environment.age".publicKeys = [ ruwusch ];
  "Affine/Postgres.age".publicKeys = [ ruwusch ];
  "Affine/Redis.age".publicKeys = [ ruwusch ];

  "PhotoPrism.age".publicKeys = [ ruwusch ];
  "Piwigo-Mariadb.age".publicKeys = [ ruwusch ];

  "Monitoring/Exporters/Nextcloud-Token.age".publicKeys = [ ruwusch ];
  "Monitoring/Exporters/PhotoPrism-Token.age".publicKeys = [ ruwusch ];
  "Monitoring/Exporters/Syncthing.age".publicKeys = [ ruwusch ];
}
