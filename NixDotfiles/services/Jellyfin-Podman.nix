{ pkgs, config, lib, ... }:
let DATA_DIR = "/data/Jellyfin"; in
{
  systemd.tmpfiles.rules = [
    "d ${DATA_DIR}/jellyfin/ 0750 jellyfin jellyfin"
    "d ${DATA_DIR}/Media-Emily/ 0750 jellyfin jellyfin"
    "d ${DATA_DIR}/Media-Carsten/ 0750 jellyfin jellyfin"
  ];

  imports = [
    (
      import ./Container-Config/Oci-Container.nix {
        inherit config lib;
        name = "jellyfin";
        image = "linuxserver/jellyfin:latest";

        subdomain = "jelly";
        containerIP = "10.88.3.1";
        containerPort = 8096;
        environment = {
          PUID = "5009";
          PGID = "5009";
          DOCKER_MODS="linuxserver/mods:jellyfin-opencl-intel";
        };
        additionalContainerConfig.extraOptions = [ "--device=/dev/dri:/dev/dri" "--privileged" ];

        volumes = [
          "${DATA_DIR}/jellyfin:/config"
          "${DATA_DIR}/Media-Emily:/data/Media-Emily"
          "/data/Transmission/data:/data/data"
        ];
      }
    )
  ];
}
