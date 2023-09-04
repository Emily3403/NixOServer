{ pkgs, config, lib, ...}: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    dataDir = "/data/postgresql";
    settings.listen_addresses = lib.mkForce "*";
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    dataDir = "/data/mysql";
  };
}