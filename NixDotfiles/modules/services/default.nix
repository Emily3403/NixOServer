{ config, lib, pkgs, ... }:
let
  inherit (lib) types mkOption;
  format = pkgs.formats.json { };
in
{
  imports = [ ./Keycloak.nix ];

  options.domainName = mkOption {
    type = types.str;
    description = "Domain name to be used";
  };

  options.containerHostIP = mkOption {
    type = types.str;
    description = "IP to be used for the nixos-containers";
  };

}
