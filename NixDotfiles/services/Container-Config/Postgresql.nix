{ name, pkgs, lib }: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;

    ensureDatabases = [ name ];
    ensureUsers = [{
      name = name;
      ensureDBOwnership = true;
    }];
  };


}
