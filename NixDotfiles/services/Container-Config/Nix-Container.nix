{ name
, subdomain ? null
, fqdn ? null
, cID /* Integer ID that counts up from 1 */
, containerPort /* int */
, additionalPorts ? []
, bindMounts
, user ? null /* attrset with optional name, uid, gid, isNormalUser / isSystemUser */
, isSystemUser ? false
, group ? null /* Same here except the attrs from group */
, imports ? [ ]
, postgresqlName ? null
, additionalDomains ? [ ]
, additionalContainerConfig ? { }
, makeNginxConfig ? true
, nginxLocation ? "/"
, nginxMaxUploadSize ? null
, additionalNginxConfig ? { }
, additionalNginxLocationConfig ? { }
, additionalNginxHostConfig ? { }
, enableHardwareTranscoding ? false
, cfg
, lib
, config
, pkgs
}:
let

  inherit (lib) mkIf optional optionals mkMerge;
  utils = import ../../utils.nix { inherit config lib; };
  stateVersion = config.system.stateVersion;
  containerIP = utils.makeNixContainerIP cID;

  pgImport = if postgresqlName == null then [ ] else [
    (
      import ./Postgresql.nix {
        inherit pkgs lib;
        name = postgresqlName;
      }
    )
  ];

  userConfig =
    let
      userAttrs = if user == null then { } else user;
      groupAttrs = if group == null then { } else group;

      userName = if builtins.hasAttr "name" userAttrs then user.name else name;
      groupName = if builtins.hasAttr "name" groupAttrs then group.name else userName;
      uid = if builtins.hasAttr "uid" userAttrs then user.uid else containerID + 12000;
      usingPg = (pgImport == [ ]);
    in
    {
      users = {
        "${userName}" = {
          uid = uid;
          isNormalUser = !isSystemUser;
          isSystemUser = isSystemUser;

          name = userName;
          group = userName;

          password = "!"; # Always disallow login
        } // userAttrs;

        "postgres" = mkIf usingPg {
          uid = 71;
          group = "postgres";
        };
      };

      groups = {
        "${groupName}" = {
          gid = uid;
          members = [ userName ];
        } // groupAttrs;

        postgres.members = optional usingPg "postgres";
      };
    };


in
{
  imports = imports ++ [(
    import ./Nginx.nix {
      inherit containerIP fqdn config additionalDomains lib containerPort;
      enable = makeNginxConfig;
      subdomain = if subdomain != null then subdomain else name;
      location = nginxLocation;
      additionalConfig = additionalNginxConfig;
      additionalLocationConfig = additionalNginxLocationConfig;
      additionalHostConfig = additionalNginxHostConfig;
    }
  )];

  users = userConfig;

  hardware.graphics = mkIf enableHardwareTranscoding {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver intel-compute-runtime-legacy1 ];
  };

  containers."${name}" = utils.recursiveMerge [
    additionalContainerConfig
    {
      autoStart = true;
      privateNetwork = true;
      hostAddress = config.host.networking.containerHostIP;
      localAddress = containerIP;
      timeoutStartSec = "15min";  # Give containers all the time they need to start up

      bindMounts = mkMerge [ bindMounts (mkIf enableHardwareTranscoding { "/dev/dri" = { hostPath = "/dev/dri"; isReadOnly = false; }; }) ];
      allowedDevices = optionals (enableHardwareTranscoding) [{ node = "/dev/dri/renderD128"; modifier = "rw"; } { node = "/dev/dri/card0"; modifier = "rw"; }];

      config = { pkgs, config, lib, ... }: utils.recursiveMerge [
        cfg
        {
          system.stateVersion = stateVersion;
          nixpkgs.config.allowUnfree = true;
          networking.firewall.allowedTCPPorts = [ containerPort ] ++ additionalPorts;
          users = userConfig;
          imports = [ ../../users/root.nix ../../system.nix ] ++ imports ++ pgImport;

          hardware.graphics = mkIf enableHardwareTranscoding {
            enable = true;
            extraPackages = with pkgs; [ intel-media-driver intel-compute-runtime-legacy1 ];
          };

          environment.sessionVariables = mkIf enableHardwareTranscoding { LIBVA_DRIVER_NAME = "iHD"; };
        }
      ];
    }
  ];
}
