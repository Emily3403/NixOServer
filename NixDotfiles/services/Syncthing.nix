{ pkgs, inputs, config, lib, ... }:
let
  cfg = config.host.services.syncthing;
  utils = import ../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 1;
in
{

  options.host.services.syncthing = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/Syncthing";
    };

    subdomain = mkOption {
      type = types.str;
      default = "sync";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 syncthing syncthing"
      "d ${cfg.dataDir}/syncthing 0750 syncthing syncthing"
    ];

    networking.firewall = {
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [ 21027 22000 ];
    };

    age.secrets.Prometheus_Syncthing-exporter  = mkIf cfg.enableExporter {
      file = ../secrets/nixie/Monitoring/Exporters/${config.host.name}/Syncthing.age;
      owner = "root";
    };

    services.nginx.virtualHosts."${config.host.networking.monitoringDomain}" = mkIf cfg.enableExporter (utils.makeNginxBearerMetricConfig "syncthing" (utils.makeNixContainerIP containerID) "8080");

  };

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config inputs lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "syncthing";
        containerPort = 8080;

        user.uid = 237;
        isSystemUser = true;

        additionalContainerConfig.forwardPorts = [{ hostPort = 22000; } { hostPort = 22000; protocol = "udp"; } { hostPort = 21027; protocol = "udp"; }];

        bindMounts = {
          "/var/lib/syncthing/" = { hostPath = "${cfg.dataDir}/syncthing"; isReadOnly = false; };
        };

        cfg = {
          services.syncthing = {
            enable = true;

            overrideFolders = false;
            overrideDevices = true;

            guiAddress = "0.0.0.0:8080";
            openDefaultPorts = true;

            settings = {
              options = {
                urAccepted = -1;
                maxFolderConcurrency = 8; # Turn this down if using HDDs
                databaseTuning = "large";
              };

              devices =
                let
                  defconfig = {
                    introducer = false;
                    autoAcceptFolders = true;
                  };
                in
                {

                  UwU = { id = "3P2KUWI-C7GCARO-LAHCSIB-M3O7LE7-X4RFYQ6-7HNFJ7I-Y72NUOV-3HNYAAA"; } // defconfig;
                  UwUonWindows = { id = "XSQSL6O-RBBBCWY-DO44ILU-AT6DCSR-F5QR7U4-E4ZQHBT-RVSLUWK-CWWUTQ7"; } // defconfig;
                  Cashew = { id = "6OGY4LN-KQ3XE33-X5QIWVN-IUZ6F5E-7DNZHQ6-7DVBR6G-FIVWZPC-GMKYXQN"; } // defconfig;

                  Pixel = { id = "XLVNMQQ-Q7UNI5E-IR3PCGW-OYHIM5Z-W2ZAWLQ-SIT7ZUG-IDYNMPO-ODTDYQ6"; } // defconfig;

                  OwO = { id = "PZE3EAA-W6LXTIY-XUPBPL7-2TKLG35-ZPUY27U-6PP6ECF-UHVGBEJ-AI4RAQJ"; } // defconfig;
                  MightyMarshmellow = { id = "JB4YIH6-TXCJIWD-LRWIQYK-D6EUPAD-ER2BCUA-NEGOXO5-R4AUKI6-ME6QOAQ"; } // defconfig;
                  JellyfinPlayer = { id = "ZNNKUJ7-XD4OPT5-7QEDWVD-DME43EB-B7LCOBP-EIPIYM7-ZKMS5QA-SS7WPA2"; } // defconfig;
                };
            };
          };
        };
      }
    )

    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib pkgs;
        enable = cfg.enableExporter;
        dataDir = cfg.dataDir;
        fqdn = config.host.networking.monitoringDomain;

        name = "syncthing-exporter";
        image = "f100024/syncthing_exporter:0.3.12";
        containerID = 25;

        containerPort = 9093;
        nginxLocation = "/syncthing-exporter-metrics";
        nginxProxyPassLocation = "/metrics";

        environmentFiles = [ config.age.secrets.Prometheus_Syncthing-exporter.path ];
        environment = {
          SYNCTHING_URI = "https://${cfg.subdomain}.${config.host.networking.domainName}";
          SYNCTHING_TIMEOUT = "60s";
        };
      }
    )

  ];
}
