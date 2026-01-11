{ pkgs, inputs, config, lib, ... }:
let
  cfg = config.host.services.headscale;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 21;
in
{
  options.host.services.headscale = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Headscale";
    };

    subdomain = mkOption {
      type = types.str;
      default = "headscale";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 headscale"
      "d ${cfg.dataDir}/headscale 0750 headscale"
      "f ${cfg.dataDir}/headscale/acls.json 0640 headscale"
    ];

    age.secrets.Headscale = {
      file = ../../secrets/${config.host.name}/VPN/Headscale.age;
      owner = "headscale";
    };
  };

  imports = [
    (
      import ../Container-Config/Nix-Container.nix {
        inherit config inputs lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "headscale";
        containerPort = 8080;
        isSystemUser = true;
        additionalNginxLocationConfig.proxyWebsockets = true;

        bindMounts = {
          "/var/lib/headscale/" = { hostPath = "${cfg.dataDir}/headscale"; isReadOnly = false; };
          "${config.age.secrets.Headscale.path}".hostPath = config.age.secrets.Headscale.path;
        };

        cfg = {
          services.headscale = {
            enable = true;
            address = "0.0.0.0";

            settings = {
              server_url = "https://${cfg.subdomain}.${config.host.networking.domainName}";
              dns = {
                base_domain = "ruwusch";  # access devices with device.ruwusch
                nameservers.global = config.networking.nameservers;
                search_domains = [ "ruwusch" ];
              };

              oidc = {
                issuer = "https://${config.host.services.keycloak.subdomain}.${config.host.services.keycloak.domain}/realms/${config.host.services.keycloak.realm}";
                client_id = "Headscale";
                client_secret_path = config.age.secrets.Headscale.path;
              };

              policy = {
                mode = "file";
                path = "/var/lib/headscale/acls.json";
              };
            };
          };
        };
      }
    )
  ];
}
