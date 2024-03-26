{ pkgs, options, config, lib, ... }: {
  age.secrets = {
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
      owner = "5000";
    };

    Wireguard = {
      file = ../../secrets/Wireguard.age;
      owner = "root";
    };

    PhotoPrism = {
      file = ../../secrets/PhotoPrism.age;
      owner = "photoprism";
    };

  };
}
