{ pkgs, config, lib, inputs, ... }: {
  users.mutableUsers = false;

  # Don't build man pages. This saves a *lot* of time when rebuilding
  documentation.man.generateCaches = false;

  users.users = {
    postgres = {
      uid = 71;
      group = "postgres";
    };
  };

  users.groups.postgres.members = [ "postgres" ];
}
