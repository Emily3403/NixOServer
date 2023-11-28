{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    KeyCloak_DatabasePassword = {
      file = ./KeyCloak/DatabasePassword.age;
      owner = "keycloak";
    };

    KeyCloak_AdminPassword = {
      file = ./KeyCloak/AdminPassword.age;
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
      file = ./Wiki-js/ssh_key.age;
      owner = "wiki-js";
    };

    Transmission_EnvironmentFile = {
      file = ./Transmission/EnvironmentFile.age;
      owner = "5000";
    };

  };
}
