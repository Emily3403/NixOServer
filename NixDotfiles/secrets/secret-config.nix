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
      path = "/etc/wiki";
    };


  };
}