{ config, ... }: {
  users.groups.mysql.members = [ "mysql" ];

  users.users = {
    mysql = {
      uid = 84;
      group = "mysql";
    };
  };
}
