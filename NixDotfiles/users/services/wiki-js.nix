{ ... }: {
  imports = [ ./postgres.nix ];

  users.users = {
    wiki-js = {
      isNormalUser = true;
      uid = 5001;
    };
  };
}
