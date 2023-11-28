{ dbName, dbUser, pkgs }: {
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;

    ensureDatabases = [ dbName ];
    ensureUsers = [
      {
        name = dbUser;
        ensurePermissions = { "DATABASE ${dbName}" = "ALL PRIVILEGES"; };
        ensureClauses.superuser = true;
      }
    ];
  };
}
