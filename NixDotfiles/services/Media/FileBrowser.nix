{ pkgs, inputs, config, lib, ... }:
let
  cfg = config.host.services.filebrowser;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 27;
in
{
  options.host.services.filebrowser = {
    dataDir = mkOption {
      type = types.str;
      default = "/data/FileBrowser";
    };

    subdomain = mkOption {
      type = types.str;
      default = "files";
    };

    enableExporter = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 jellyfin"
      "d ${cfg.dataDir}/filebrowser 0750 jellyfin"
    ];
  };

  imports = [
    (
      import ../Container-Config/Oci-Container.nix {
        inherit config lib pkgs containerID;
        dataDir = cfg.dataDir;
        subdomain = cfg.subdomain;

        name = "filebrowser";
        image = "filebrowser/filebrowser:v2.32.0";

        additionalNginxConfig.extraConfig = "client_max_body_size 1G;";
        containerPort = 80;

        volumes = [
          "${cfg.dataDir}/data:/data"
          "${config.host.services.transmission.dataDir}/data:/data/transmission:ro"

          "${cfg.dataDir}/filebrowser/state.db:/state.db"
          "${cfg.dataDir}/filebrowser/.filebrowser.json:/.filebrowser.json"
        ];
      }
    )
  ];
}
