{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Syncthing"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/syncthing 0755 syncthing"
  ];

  imports = [(
    import ./Container-Config/Nix-Container.nix {
      inherit config lib;

      name = "syncthing";
      containerIP = "192.168.7.105";
      containerPort = 8080;

      imports = [ ../users/services/syncthing.nix ];
      bindMounts = {
        "/var/lib/syncthing/" = { hostPath = "${DATA_DIR}/syncthing"; isReadOnly = false; };
      };

      cfg = {
        services.syncthing = {
          enable = true;
          overrideFolders = false;
          guiAddress = "0.0.0.0:8080";
          openDefaultPorts = true;

          devices =
          let defconfig = {
            introducer = true;
            autoAcceptFolders = true;
          }; in {

            nyaa = { id = "6OGY4LN-KQ3XE33-X5QIWVN-IUZ6F5E-7DNZHQ6-7DVBR6G-FIVWZPC-GMKYXQN"; } // defconfig;
            UwU = { id = "3P2KUWI-C7GCARO-LAHCSIB-M3O7LE7-X4RFYQ6-7HNFJ7I-Y72NUOV-3HNYAAA"; } // defconfig;
            MightyMarshmellow = { id = "JB4YIH6-TXCJIWD-LRWIQYK-D6EUPAD-ER2BCUA-NEGOXO5-R4AUKI6-ME6QOAQ"; } // defconfig;

          };
        };
      };
    }
  )];
}
