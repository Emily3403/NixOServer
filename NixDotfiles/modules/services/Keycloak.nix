{ config, lib, pkgs, ... }:
let
  inherit (lib) types mkOption;
  format = pkgs.formats.json {};
in
{

  options.keycloak-setup = mkOption {
    default = {};
    type = types.submodule {
      freeformType = format.type;
      options = {

        subdomain = mkOption {
          type = types.str;
          default = "keycloak";
        };

        domain = mkOption {
          type = types.str;
          default = config.domainName;
        };

        name = mkOption {
          type = types.str;
          default = "Keycloak";
        };

        realm = mkOption {
          type = types.str;
          default = "master";
        };

        attributeMapper = let options = {

            username = mkOption {
              type = types.str;
              default = "preferred_username";
              description = "The attribute for the username.";
            };

            name = mkOption {
              type = types.str;
              default = "name";
            };

            email = mkOption {
              type = types.str;
              default = "email";
            };

            groups = mkOption {
              type = types.str;
              default = "groups";
            };

        };
      in mkOption
      {
        type = types.submodule {
          freeformType = format.type;
          inherit options;
        };
        default = {};
      };

      };
    };
  };
}