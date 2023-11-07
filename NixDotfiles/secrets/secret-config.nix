{ pkgs, options, config, lib, ...}: {
  age.secrets = {
    KeyCloakDatabasePassword = {
      file = ./KeyCloak/DatabasePassword.age;
      owner = "keycloak";
    };

    KeyCloakAdminPassword = {
      file = ./KeyCloak/AdminPassword.age;
      owner = "keycloak";
    };

    KeyCloakSSLCert = {
      file = ./KeyCloak/SSL_Cert.age;
      owner = "nginx";
    };

    KeyCloakSSLKey = {
      file = ./KeyCloak/SSL_Key.age;
      owner = "nginx";
    };

    NextcloudAdminPassword = {
      file = ./Nextcloud/AdminPassword.age;
      owner = "nextcloud";
    };

    NexcloudKeycloakClientSecret = {
      file = ./Nextcloud/KeycloakClientSecret.age;
      owner = "nextcloud";
    };

    HedgeDocEnvironmentFile = {
      file = ./HedgeDoc/EnvironmentFile.age;
      owner = "hedgedoc";
    };

    VaultWardenEnvironmentFile = {
      file = ./VaultWarden/EnvironmentFile.age;
      owner = "vaultwarden";
    };

    MailManEnvironmentFile = {
      file = ./Mail/MailManEnvironmentFile.age;
      owner = "5000";
      group = "5000";
    };

    MailManDatabasePassword = {
      file = ./Mail/MailManEnvironmentFile.age;
      owner = "5000";
      group = "5000";
    };

    MailEnvironmentFile = {
      file = ./Mail/EnvironmentFile.age;
      owner = "root";
      group = "root";
    };

    MailSSLCerts = {
      file = ./Mail/ssl_certs.age;
      owner = "root";
      group = "root";
    };

    SSHKey = {
      file = ./ssh_key.age;
      owner = "wiki-js";
      path = "/etc/wiki";
    };


  };
}