{ pkgs, config, lib, inputs, ... }: {
  users.mutableUsers = false;

  # Don't build man pages. This saves a *lot* of time when rebuilding
  documentation.man.generateCaches = false;

  users.users = {
    postgres = {
      uid = config.ids.uids.postgres;
      group = "postgres";
    };

    mysql = {
      uid = config.ids.uids.mysql;
      group = "mysql";
    };
  };

  users.groups.postgres.members = [ "postgres" ];
  users.groups.mysql.members = [ "mysql" ];
}
