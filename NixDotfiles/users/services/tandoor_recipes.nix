{ ... }: {
  imports = [ ./postgres.nix ];
  users.groups.tandoor_recipes.members = [ "tandoor_recipes" ];

  users.users = {
    tandoor_recipes = {
      isSystemUser = true;
      uid = 5012;
      group = "tandoor_recipes";
    };
  };
}
