let
  ruwusch = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJwG99nxyrMgSpHEgtexFQ96w5VaNf2zgR7Hm1bFHsMe root@ruwusch";
  nixie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDl1EuW3ahRjtYzafPWux9fQqqblfq3TmNS62dwX2Xcz root@nixie";
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

  "nixie/Monitoring/Grafana-admin-pw.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Grafana-secret-key.age".publicKeys = [ nixie ];

  "nixie/Monitoring/Access/nixie.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Access/ruwusch.age".publicKeys = [ nixie ];
  "nixie/Monitoring/Access/Syncthing.age".publicKeys = [ nixie ];
#  "nixie/.age".publicKeys = [ nixie ];




  # Ruwusch
  "ruwusch/Keycloak.age".publicKeys = [ ruwusch ];
  "ruwusch/HedgeDoc.age".publicKeys = [ ruwusch ];


  "ruwusch/Wireguard.age".publicKeys = [ ruwusch ];
  "ruwusch/Transmission.age".publicKeys = [ ruwusch ];
  "ruwusch/Nextcloud/admin-password.age".publicKeys = [ ruwusch ];
  "ruwusch/Nextcloud/keycloak-client-secret.age".publicKeys = [ ruwusch ];
#  "ruwusch/.age".publicKeys = [ ruwusch ];
#  "ruwusch/.age".publicKeys = [ ruwusch ];
#  "ruwusch/.age".publicKeys = [ ruwusch ];



  # Shared


  "Keycloak/DatabasePassword.age".publicKeys = [ ruwusch ];
  "Keycloak/AdminPassword.age".publicKeys = [ ruwusch ];

  "Nextcloud/AdminPassword.age".publicKeys = [ ruwusch ];
  "Nextcloud/KeycloakClientSecret.age".publicKeys = [ ruwusch ];

  "Affine/Environment.age".publicKeys = [ ruwusch ];
  "Affine/Postgres.age".publicKeys = [ ruwusch ];
  "Affine/Redis.age".publicKeys = [ ruwusch ];

  "Ente/Env.age".publicKeys = [ ruwusch ];
  "Ente/Postgres.age".publicKeys = [ ruwusch ];
  "Ente/Minio.age".publicKeys = [ ruwusch ];

  "HedgeDoc.age".publicKeys = [ ruwusch ];
  "Transmission.age".publicKeys = [ ruwusch ];
  "Luk-Docs.age".publicKeys = [ ruwusch ];
  "Wireguard.age".publicKeys = [ ruwusch ];
  "PhotoPrism.age".publicKeys = [ ruwusch ];
  "Tandoor.age".publicKeys = [ ruwusch ];
  "Piwigo-Mariadb.age".publicKeys = [ ruwusch ];

  "SSHKeys/wiki-js.age".publicKeys = [ ruwusch ];

  "Monitoring/Grafana/admin-pw.age".publicKeys = [ ruwusch ];
  "Monitoring/Grafana/secret-key.age".publicKeys = [ ruwusch ];

  "Monitoring/Prometheus/ruwusch-pw.age".publicKeys = [ ruwusch ];
  "Monitoring/Nginx/ruwusch-htpasswd.age".publicKeys = [ ruwusch ];

  "Monitoring/Exporters/Transmission.age".publicKeys = [ ruwusch ];
  "Monitoring/Exporters/Syncthing.age".publicKeys = [ ruwusch ];
  "Monitoring/Exporters/Syncthing-API-Key.age".publicKeys = [ ruwusch ];
  "Monitoring/Exporters/Nextcloud-Token.age".publicKeys = [ ruwusch ];
  "Monitoring/Exporters/PhotoPrism-Token.age".publicKeys = [ ruwusch ];
}
