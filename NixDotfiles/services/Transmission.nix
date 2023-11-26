{ pkgs, config, lib, ...}:
  let DATA_DIR = "/data/Transmission"; in
{

  imports = [(
    import ./Container-Config/Oci-Container.nix {
      inherit config;
      name = "transmission";
      image = "haugene/transmission-openvpn:latest";

      subdomain = "transui";
      containerIP = "10.88.2.1";
      containerPort = 9091;
      additionalOptions = [ "--cap-add=NET_ADMIN,mknod" "--device=/dev/net/tun" ];

      volumes = [
        "${DATA_DIR}/data:/data"
        "${DATA_DIR}/config:/config"
      ];

      environmentFiles = [ config.age.secrets.Transmission_EnvironmentFile.path ];
  })];

  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/data/ 0750 1001 1001"
    "d ${DATA_DIR}/config/ 0750 1001 1001"
  ];
}
