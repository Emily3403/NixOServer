{ pkgs, config, lib, ... }:
let
  cfg = config.host.services.syncthing;
  inherit (lib) mkIf mkOption types;
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

    age.secrets = mkIf cfg.enableExporter {
      Prometheus_syncthing-exporter-environment = {
        file = ../secrets/${config.host.name}/Monitoring/Exporters/Syncthing-Exporter.age;
        owner = "root";
      };
    };
  };

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;

        name = "syncthing";
        subdomain = config.host.services.syncthing.subdomain;
        containerID = 1;
        containerPort = 8080;

        user.uid = 237;
        isSystemUser = true;

        additionalContainerConfig.forwardPorts = [ { hostPort = 22000; } { hostPort = 22000; protocol = "udp"; } { hostPort = 21027; protocol = "udp"; } ];

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
                maxFolderConcurrency = 8;  # Turn this down if using HDDs
              };

              devices =
                let
                  defconfig = {
                    introducer = false;
                    autoAcceptFolders = true;
                  };
                in
                {

                  nyaa = { id = "6OGY4LN-KQ3XE33-X5QIWVN-IUZ6F5E-7DNZHQ6-7DVBR6G-FIVWZPC-GMKYXQN"; } // defconfig;
                  UwU = { id = "3P2KUWI-C7GCARO-LAHCSIB-M3O7LE7-X4RFYQ6-7HNFJ7I-Y72NUOV-3HNYAAA"; } // defconfig;
                  OwO = { id = "PZE3EAA-W6LXTIY-XUPBPL7-2TKLG35-ZPUY27U-6PP6ECF-UHVGBEJ-AI4RAQJ"; } // defconfig;
                  MightyMarshmellow = { id = "JB4YIH6-TXCJIWD-LRWIQYK-D6EUPAD-ER2BCUA-NEGOXO5-R4AUKI6-ME6QOAQ"; } // defconfig;
                  Pixel = { id = "XLVNMQQ-Q7UNI5E-IR3PCGW-OYHIM5Z-W2ZAWLQ-SIT7ZUG-IDYNMPO-ODTDYQ6"; } // defconfig;
                  JellyfinPlayer = { id = "REBDHNA-MYY6MQY-RQKI7T3-2BPGKST-3NJN3J4-UD7PGUF-TI7WXWX-RPUECQD"; } // defconfig;
                  UwUonWindows = { id = "XSQSL6O-RBBBCWY-DO44ILU-AT6DCSR-F5QR7U4-E4ZQHBT-RVSLUWK-CWWUTQ7"; } // defconfig;

                };
            };
          };
        };
      }
    )
  ];
}
