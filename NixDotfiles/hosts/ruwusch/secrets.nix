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
      file = ../../secrets/HedgeDoc/EnvironmentFile.age;
      owner = "hedgedoc";
    };

    WikiJs_SSHKey = {
      file = ../../secrets/SSHKeys/Wiki-js/key.age;
      owner = "wiki-js";
    };

    Transmission_EnvironmentFile = {
      file = ../../secrets/Transmission/EnvironmentFile.age;
      owner = "5000";
    };

#    Wireguard = {
#      file = ../../secrets/Wireguard/Wireguard.age;
#      owner = "root";
#    };

  };
}
