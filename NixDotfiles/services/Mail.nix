{ pkgs, config, lib, ...}: {

  services.nginx.virtualHosts = {
    "new-mail.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      serverAliases = [ "mail1.${config.domainName}" "mail.${config.domainName}" ];
    };
  };

  virtualisation.oci-containers.containers.mail = {
    image = "mailserver/docker-mailserver:latest";

    ports = [
      "25:25"
      "465:465"
      "587:587"
      "993:993"
    ];

    volumes =
    [
      "/data/Mail/mail-data:/var/mail"
      "/data/Mail/mail-state:/var/mail-state"
      "/data/Mail/mail-logs:/var/log/mail"
      "/data/Mail/config:/tmp/docker-mailserver"
      "/etc/localtime:/etc/localtime"
      "${config.age.secrets.MailSSLCerts.path}:${config.age.secrets.MailSSLCerts.path}"
      "${config.age.secrets.MailEnvironmentFile.path}:${config.age.secrets.MailEnvironmentFile.path}"
      "/var/lib/acme/new-mail.inet.tu-berlin.de/:/var/lib/acme/new-mail.inet.tu-berlin.de/:ro"
    ];

    environmentFiles = [ config.age.secrets.MailEnvironmentFile.path ];

    environment = {
      OVERRIDE_HOSTNAME = "mail.${config.domainName}";
      LOG_LEVEL = "trace";
      TZ = "Europe/Berlin";
      ONE_DIR = "1";

      SSL_TYPE = "manual";
      SSL_CERT_PATH = "/var/lib/acme/new-mail.inet.tu-berlin.de/fullchain.pem";
      SSL_KEY_PATH = "/var/lib/acme/new-mail.inet.tu-berlin.de/key.pem";

      # TODO
      ENABLE_AMAVIS = "0";
      ENABLE_OPENDKIM = "0";
      ENABLE_OPENDMARC = "0";
      ENABLE_POLICYD_SPF = "0";
      ENABLE_CLAMAV = "0";

    };




  };


  users.users = {
    postgres = {
      uid = 71;
    };
  };

  systemd.tmpfiles.rules = [
    "d /data/Mail/mail-data/ 0755 root"
    "d /data/Mail/mail-state/ 0755 root"
    "d /data/Mail/mail-logs/ 0755 root"
    "d /data/Mail/config/ 0755 root"
  ];

}