{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Keycloak_DatabasePassword = {
      file = ./Keycloak/DatabasePassword.age;
      owner = "keycloak";
    };

    Keycloak_AdminPassword = {
      file = ./Keycloak/AdminPassword.age;
      owner = "keycloak";
    };

    Nextcloud_AdminPassword = {
      file = ./Nextcloud/AdminPassword.age;
      owner = "nextcloud";
    };

    Nexcloud_KeycloakClientSecret = {
      file = ./Nextcloud/KeycloakClientSecret.age;
      owner = "nextcloud";
    };

    HedgeDoc_EnvironmentFile = {
      file = ./HedgeDoc/EnvironmentFile.age;
      owner = "hedgedoc";
    };

    WikiJs_SSHKey = {
      file = ./SSHKeys/Wiki-js/key.age;
      owner = "wiki-js";
    };

    Transmission_EnvironmentFile = {
      file = ./Transmission/EnvironmentFile.age;
      owner = "5000";
    };

#    Wireguard = {
#      file = ./Wireguard/Wireguard.age;
#      owner = "root";
#    };

  };
}
