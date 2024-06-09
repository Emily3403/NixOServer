{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Tandoor"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR} 0750 tandoor_recipes"
    "d ${DATA_DIR}/tandoor-recipes 0750 tandoor_recipes"
    "d ${DATA_DIR}/postgresql 0750 postgres"
  ];

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;
        name = "tandoor";
        subdomain = "tandoor";
        additionalDomains = [ "recipes" ];
        containerIP = "192.168.7.111";
        containerPort = 8080;
        postgresqlName = "tandoor_recipes";

        imports = [ ../users/services/tandoor_recipes.nix ];
        bindMounts = {
          "/var/lib/tandoor-recipes/" = { hostPath = "${DATA_DIR}/tandoor-recipes"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${DATA_DIR}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.Tandoor.path}".hostPath = config.age.secrets.Tandoor.path;
        };

        cfg = {
          services.tandoor-recipes = {
            enable = true;
            address = "0.0.0.0";

            extraConfig = {
              SECRET_KEY_FILE = config.age.secrets.Tandoor.path;
              ALLOWED_HOSTS = "tandoor.${config.domainName},recipes.${config.domainName}";

              DB_ENGINE = "django.db.backends.postgresql";
              POSTGRES_HOST = "/run/postgresql/";
              POSTGRES_DB = "tandoor_recipes";
              POSTGRES_USER = "tandoor_recipes";

              ENABLE_METRICS = 0;  # Once Prometheus is set up, this can be enabled
              TZ = "Europe/Berlin";
            };
          };
        };
      }
    )
  ];
}
