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
      file = ./SSHKeys/Wiki-js/key.age;
      owner = "wiki-js";
    };

    Transmission_EnvironmentFile = {
      file = ./Transmission/EnvironmentFile.age;
      owner = "5000";
    };

    Duplicati_SSHKey_Nixie = {
      file = ./SSHKeys/Duplicati/nixie.age;
      owner = "1000";
    };

    Borg_Encrytpion_Nixie = {
      file = ./Borg/nixie.age;
      owner = "borg";
    };

    Headscale_ClientSecret = {
      file = ./Headscale/ClientSecret.age;
      owner = "headscale";
    };

  };
}
