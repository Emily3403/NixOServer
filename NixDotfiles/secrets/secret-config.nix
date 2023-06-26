{ pkgs, options, config, lib, ...}: {
  age.secrets = {
    KeyCloakDatabasePassword = {
      file = ./KeyCloak/DatabasePassword.age;
      owner = "mysql";
      group = "mysql";
    };

    KeyCloakAdminPassword = {
      file = ./KeyCloak/AdminPassword.age;
      owner = "mysql";
      group = "mysql";
    };

    NextcloudAdminPassword = {
      file = ./Nextcloud/AdminPassword.age;
      owner = "nextcloud";
      group = "nextcloud";
    };

    NexcloudKeycloakClientSecret = {
      file = ./Nextcloud/KeycloakClientSecret.age;
      owner = "nextcloud";
      group = "nextcloud";
    };

    SSLCert = {
      file = ./ssl_cert.age;
      owner = "nginx";
      group = "nginx";
    };

    SSLKey = {
      file = ./ssl_key.age;
      owner = "nginx";
      group = "nginx";
    };

    SSHKey = {
      file = ./ssh_key.age;
      owner = "wiki-js";
      group = "wiki-js";
    };

  };
}