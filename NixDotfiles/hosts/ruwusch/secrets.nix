{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Monitoring_host-htpasswd = {
      file = ../../secrets/Monitoring/Nginx/ruwusch-htpasswd.age;
      owner = "nginx";
      group = "nginx";
    };

    Prometheus_ruwusch-pw = {
      file = ../../secrets/Monitoring/Prometheus/ruwusch-pw.age;
      owner = "prometheus";
      mode = "440";
    };

    Grafana_admin-pw = {
      file = ../../secrets/Monitoring/Grafana/admin-pw.age;
      owner = "grafana";
    };

    Grafana_secret-key = {
      file = ../../secrets/Monitoring/Grafana/secret-key.age;
      owner = "grafana";
    };

    Keycloak_DatabasePassword = {
      file = ../../secrets/Keycloak/DatabasePassword.age;
      owner = "keycloak";
    };

    Keycloak_AdminPassword = {
      file = ../../secrets/Keycloak/AdminPassword.age;
      owner = "keycloak";
    };

    Nextcloud_AdminPassword = {
      file = ../../secrets/Nextcloud/AdminPassword.age;
      owner = "nextcloud";
    };

    Nexcloud_KeycloakClientSecret = {
      file = ../../secrets/Nextcloud/KeycloakClientSecret.age;
      owner = "nextcloud";
    };

    HedgeDoc_EnvironmentFile = {
      file = ../../secrets/HedgeDoc.age;
      owner = "hedgedoc";
    };

    LukDocs_EnvironmentFile = {
      file = ../../secrets/Luk-Docs.age;
      owner = "root";
    };

    WikiJs_SSHKey = {
      file = ../../secrets/SSHKeys/wiki-js.age;
      owner = "wiki-js";
    };

    Transmission_EnvironmentFile = {
      file = ../../secrets/Transmission.age;
      owner = "root";
    };

    Transmission_Exporter-environment = {
      file = ../../secrets/Monitoring/Exporters/Transmission.age;
      owner = "root";
    };

    Prometheus_SyncthingExporter-environment = {
      file = ../../secrets/Monitoring/Exporters/Syncthing-Exporter.age;
      owner = "root";
    };

    Prometheus_syncthing-API-key = {
      file = ../../secrets/Monitoring/Exporters/Syncthing-Token.age;
      owner = "prometheus";
    };

    Prometheus_photoprism-API-key = {
      file = ../../secrets/Monitoring/Exporters/PhotoPrism-Token.age;
      owner = "prometheus";
    };

    Nextcloud_Exporter-tokenfile = {
      file = ../../secrets/Monitoring/Exporters/Nextcloud-Token.age;
      owner = "nextcloud-exporter";
    };

    Wireguard = {
      file = ../../secrets/Wireguard.age;
      owner = "root";
    };

    PhotoPrism = {
      file = ../../secrets/PhotoPrism.age;
      owner = "photoprism";
    };

    Tandoor = {
      file = ../../secrets/Tandoor.age;
      owner = "tandoor_recipes";
    };

    Piwigo_Mariadb = {
      file = ../../secrets/Piwigo-Mariadb.age;
      owner = "5015";
    };

    Affine_AdminPassword = {
      file = ../../secrets/Affine/Environment.age;
      owner = "root";
    };

    Affine_Postgres = {
      file = ../../secrets/Affine/Postgres.age;
      owner = "root";
    };

    Affine_Redis = {
      file = ../../secrets/Affine/Redis.age;
      owner = "root";
    };

  };
}
