{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Syncthing"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/syncthing 0755 syncthing"
  ];

  imports = [
    (
      import ./Container-Config/Nix-Container.nix {
        inherit config lib pkgs;

        name = "syncthing";
        subdomain = "sync";
        containerIP = "192.168.7.105";
        containerPort = 8080;

        imports = [ ../users/services/syncthing.nix ];
        bindMounts = {
          "/var/lib/syncthing/" = { hostPath = "${DATA_DIR}/syncthing"; isReadOnly = false; };
        };

        additionalContainerConfig.forwardPorts = [ { hostPort = 22000; } { hostPort = 22000; protocol = "udp"; } { hostPort = 21027; protocol = "udp"; } ];

        cfg = {
          services.syncthing = {
            enable = true;
            overrideFolders = false;
            guiAddress = "0.0.0.0:8080";
            openDefaultPorts = true;

            settings.devices =
              let
                defconfig = {
                  introducer = true;
                  autoAcceptFolders = true;
                };
              in
              {

                nyaa = { id = "6OGY4LN-KQ3XE33-X5QIWVN-IUZ6F5E-7DNZHQ6-7DVBR6G-FIVWZPC-GMKYXQN"; } // defconfig;
                UwU = { id = "3P2KUWI-C7GCARO-LAHCSIB-M3O7LE7-X4RFYQ6-7HNFJ7I-Y72NUOV-3HNYAAA"; } // defconfig;
                OwO = { id = "OZMTLE4-QNCFAYO-SGYCAHG-PPFQNU5-VJ7KBEI-OE3OOBT-3FQ3UGQ-HB3F5A6"; } // defconfig;
                MightyMarshmellow = { id = "JB4YIH6-TXCJIWD-LRWIQYK-D6EUPAD-ER2BCUA-NEGOXO5-R4AUKI6-ME6QOAQ"; } // defconfig;
                Pixel = { id = "XLVNMQQ-Q7UNI5E-IR3PCGW-OYHIM5Z-W2ZAWLQ-SIT7ZUG-IDYNMPO-ODTDYQ6"; } // defconfig;
                JellyfinPlayer = { id = "REBDHNA-MYY6MQY-RQKI7T3-2BPGKST-3NJN3J4-UD7PGUF-TI7WXWX-RPUECQD"; } // defconfig;
                UwUonWindows = { id = "XSQSL6O-RBBBCWY-DO44ILU-AT6DCSR-F5QR7U4-E4ZQHBT-RVSLUWK-CWWUTQ7"; } // defconfig;

              };
          };
        };
      }
    )
  ];
}
