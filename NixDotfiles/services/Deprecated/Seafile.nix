{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.seafile;
  utils = import ../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 14;
in
{
  options.host.services.seafile = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Seafile";
    };

    subdomain = mkOption {
      type = types.str;
      default = "seafile";
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 seafile nginx"
      "d ${cfg.dataDir}/seafile 0755 seafile nginx"
      "d ${cfg.dataDir}/logs 0750 seafile"
      "d ${cfg.dataDir}/mysql 0750 84"

      "d /run/seafile 0750 seafile"
      "d /run/seahub 0750 seafile"
    ];
  };

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "seafile";
        containerPort = 8083;

        isSystemUser = true;

        bindMounts = {
          "/var/lib/seafile/" = { hostPath = "${cfg.dataDir}/seafile"; isReadOnly = false; };
          "/var/log/seafile/" = { hostPath = "${cfg.dataDir}/logs"; isReadOnly = false; };
          "/var/lib/mysql/" = { hostPath = "${cfg.dataDir}/mysql"; isReadOnly = false; };

          "/run/seafile/" = { hostPath = "/run/seafile"; isReadOnly = false; };
          "/run/seahub/" = { hostPath = "/run/seahub"; isReadOnly = false; };
        };

        additionalNginxConfig = {
          locations."/media".root = "${cfg.dataDir}/seafile/seahub";

          locations."/seafhttp" = {
            proxyPass = "http://192.168.7.15:8082";
            extraConfig = ''
              rewrite ^/seafhttp(.*)$ $1 break;
              proxy_connect_timeout  3600s;
              proxy_read_timeout  3600s;
              proxy_send_timeout  3600s;
              send_timeout  3600s;
            '';
          };
        };

        cfg = let scfg = config.host.services.seafile; in {
          networking.firewall.allowedTCPPorts = [ 8082 ];

          services.seafile = {
            enable = true;

            adminEmail = "seebeckemily3403@gmail.com";
            initialAdminPassword = "changeme";

            ccnetSettings.General.SERVICE_URL = "https://${scfg.subdomain}.${config.host.networking.domainName}";

            seahubAddress = "0.0.0.0:8083";
            seafileSettings.fileserver.host = "ipv4:0.0.0.0";

#            seahubExtraConf = ''
#
#            '';

            gc.enable = true;
          };
        };
      }
    )
  ];
}
