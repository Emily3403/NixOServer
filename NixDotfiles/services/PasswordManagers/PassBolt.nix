{ pkgs, config, lib, ...}: {

  services.nginx.virtualHosts = {
    "passbolt.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://192.168.7.141:80/";
    };
  };

  virtualisation.oci-containers.containers.passbolt = {
    image = "passbolt/passbolt:latest";

    volumes = [
      "/data/PassBolt/passbolt:/var/lib/passbolt"
    ];

  };

  systemd.tmpfiles.rules = [
    "d /data/PassBolt/postgresql 0755 postgres"
    "d /data/PassBolt/passbolt 0755 passbolt"
  ];

}