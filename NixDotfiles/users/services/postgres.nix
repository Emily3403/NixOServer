{ ... }: {
  users.users = {
    postgres = {
      uid = 71;
      group = "postgres";
    };
  };

  users.groups.postgres.members = [ "postgres" ];
}
