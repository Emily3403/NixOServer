{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.tandoor;
  utils = import ../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 6;
in
{
  options.host.services.tandoor = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Tandoor";
    };

    subdomain = mkOption {
      type = types.str;
      default = "recipes";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 tandoor_recipes nginx"
      "d ${cfg.dataDir}/tandoor-recipes 0750 tandoor_recipes nginx" # Nginx has to be able to serve the images
      "d ${cfg.dataDir}/postgresql 0750 postgres"
    ];

    age.secrets.Tandoor = {
      file = ../secrets/${config.host.name}/Tandoor.age;
      owner = "tandoor_recipes";
    };
  };


  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "tandoor";
        containerPort = 8080;
        postgresqlName = "tandoor_recipes";

        additionalNginxConfig.locations = {
          "/metrics/".return = "403";
          "/media/".alias = "${cfg.dataDir}/tandoor-recipes/";
        };

        user.name = "tandoor_recipes";

        bindMounts = {
          "/var/lib/tandoor-recipes/" = { hostPath = "${cfg.dataDir}/tandoor-recipes"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${cfg.dataDir}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.Tandoor.path}".hostPath = config.age.secrets.Tandoor.path;
        };

        cfg = {
          services.tandoor-recipes = {
            enable = true;
            address = "0.0.0.0";

            extraConfig = {
              SECRET_KEY_FILE = config.age.secrets.Tandoor.path;
              ALLOWED_HOSTS = "${cfg.subdomain}.${config.host.networking.domainName}";

              DB_ENGINE = "django.db.backends.postgresql";
              POSTGRES_HOST = "/run/postgresql/";
              POSTGRES_DB = "tandoor_recipes";
              POSTGRES_USER = "tandoor_recipes";
              SOCIAL_PROVIDERS = "allauth.socialaccount.providers.openid_connect";

              ENABLE_METRICS = 0; # Once Prometheus is set up, this can be enabled
              TZ = config.host.networking.timeZone;
            };
          };
        };
      }
    )
  ];
}
