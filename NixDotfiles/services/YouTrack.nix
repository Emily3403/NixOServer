{ pkgs, config, lib, ...}: {

  services.nginx.virtualHosts = {
    "asktheadmins.${config.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://0.0.0.0:3000/";
    };
  };


  virtualisation.oci-containers.containers.youtrack = {
    image = "jetbrains/youtrack:2023.2.19783";  # TODO: This needs manual updating.

    ports = [
      "127.0.0.1:3000:8080"
    ];

    volumes =
    [
      "/data/YouTrack/data:/opt/youtrack/data"
      "/data/YouTrack/conf:/opt/youtrack/conf"
      "/data/YouTrack/logs:/opt/youtrack/logs"
      "/data/YouTrack/backups:/opt/youtrack/backups"
    ];

  };

  systemd.tmpfiles.rules = [
    "d /data/YouTrack/data/ 0750 13001 13001"
    "d /data/YouTrack/conf/ 0750 13001 13001"
    "d /data/YouTrack/logs/ 0750 13001 13001"
    "d /data/YouTrack/backups/ 0750 13001 13001"
  ];



}