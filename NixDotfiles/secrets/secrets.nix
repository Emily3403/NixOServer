let
  ruwusch = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlF4l8I+lbs3JxYRfnkULPhV+svAtoDAr0CtpjR6Rtj root@ruwusch";
in
{
  "Keycloak/DatabasePassword.age".publicKeys = [ ruwusch ];
  "Keycloak/AdminPassword.age".publicKeys = [ ruwusch ];

  "Nextcloud/AdminPassword.age".publicKeys = [ ruwusch ];
  "Nextcloud/KeycloakClientSecret.age".publicKeys = [ ruwusch ];

  "Affine/Environment.age".publicKeys = [ ruwusch ];
  "Affine/Postgres.age".publicKeys = [ ruwusch ];
  "Affine/Redis.age".publicKeys = [ ruwusch ];

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
}
