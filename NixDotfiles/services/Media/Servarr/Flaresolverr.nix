{ pkgs, inputs, config, lib, ... }:
let

  cfg = config.host.services.flaresolverr;
  utils = import ../../utils.nix { inherit config lib; };
  inherit (lib) mkIf mkOption types;

  containerID = 33;
in
{
  options.host.services.flaresolverr = {
    subdomain = mkOption {
      type = types.str;
      default = "flaresolverr";
    };
  };

  imports = [
    (
      import ../../Container-Config/Nix-Container.nix {
        inherit config inputs lib pkgs containerID;
        subdomain = cfg.subdomain;

        name = "flaresolverr";
        containerPort = 8191;

        bindMounts = {};

        cfg.services.flaresolverr.enable = true;
      }
    )
  ];
}
