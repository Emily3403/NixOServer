{ ... }: {
  imports = [ ./postgres.nix ];

  users.users = {
    keycloak = {
      isNormalUser = true;
      uid = 62384;
    };
  };
}
