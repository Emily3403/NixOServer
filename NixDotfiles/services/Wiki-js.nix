{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.wiki-js;
  inherit (lib) mkIf mkOption types;
in
{
  options.host.services.wiki-js = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Wiki-js";
    };

    subdomain = mkOption {
      type = types.str;
      default = "wiki";
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 wiki-js"
      "d ${cfg.dataDir}/postgresql 0750 postgres"
      "d ${cfg.dataDir}/wiki-js 0750 wiki-js"
    ];
    
    age.secrets.Wiki-js_ssh-key = {
      file = ../secrets/${config.host.name}/Wiki-js.age;
      owner = "wiki-js";
    };
  };
  
  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;

        name = "wiki-js";
        subdomain = cfg.subdomain;
        containerID = 5;
        containerPort = 3000;

        postgresqlName = "wiki-js";
        bindMounts = {
          "/var/lib/wiki-js/" = { hostPath = "${cfg.dataDir}/wiki-js"; isReadOnly = false; };
          "/var/lib/postgresql" = { hostPath = "${cfg.dataDir}/postgresql"; isReadOnly = false; };
          "${config.age.secrets.Wiki-js_ssh-key.path}".hostPath = config.age.secrets.Wiki-js_ssh-key.path;
        };

        cfg = {
          services.wiki-js = {
            enable = true;

            settings.db = {
              db = "wiki-js";
              host = "/run/postgresql";
              user = "wiki-js";
            };
          };
        };
      }
    )
  ];
}
