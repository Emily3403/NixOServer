{
  name, subdomain ? null, containerID /* Integer ID that counts up from 1 */,
  containerPort, bindMounts,
  user ? null /* attrset with optional name, uid, gid, isNormalUser / isSystemUser */,
  isSystemUser ? false,
  group ? null /* Same here except the attrs from group */,
  imports ? [],
  postgresqlName ? null, additionalDomains ? [ ], additionalContainerConfig ? {},
  makeNginxConfig ? true, additionalNginxConfig ? {}, additionalNginxLocationConfig ? {}, additionalNginxHostConfig ? {},
  enableHardwareTranscoding ? false,
  cfg, lib, config, pkgs
}:
let

  inherit (lib) mkIf optional optionals mkMerge;
  utils = import ../../utils.nix { inherit lib; };
  containerPortStr = if !builtins.isString containerPort then toString containerPort else containerPort;
  stateVersion = config.system.stateVersion;
  containerIP = "192.168.7.${toString (containerID + 1)}";

  pgImport = if postgresqlName == null then [] else [
    (
      import ./Postgresql.nix {
        inherit pkgs lib;
        name = postgresqlName;
      }
    )
  ];

  nginxImport = if makeNginxConfig == false then [] else [
    (
      import ./Nginx.nix {
        inherit containerIP config additionalDomains lib;
        containerPort = containerPortStr;
        subdomain = if subdomain != null then subdomain else name;
        additionalConfig = additionalNginxConfig;
        additionalLocationConfig = additionalNginxLocationConfig;
        additionalHostConfig = additionalNginxHostConfig;
      }
    )
  ];


  userConfig = let
    userAttrs = if user == null then {} else user;
    groupAttrs = if group == null then {} else group;
    userName = if builtins.hasAttr "name" userAttrs then user.name else name;
    uid = if builtins.hasAttr "uid" userAttrs then user.uid else containerID + 12000;
    usingPg = (pgImport == []);
  in {
    users = {
      "${userName}" = {
        uid = uid;
        isNormalUser = !isSystemUser;
        isSystemUser = isSystemUser;

        name = userName;
        group = userName;

        password = "!";  # Always disallow login
      } // userAttrs;

      "postgres" = mkIf usingPg {
        uid = 71;
        group = "postgres";
      };
    };

    groups = {
      "${userName}" = {
        gid = uid;
        members = [ userName ];
      } // groupAttrs;

      postgres.members = optional usingPg "postgres";
    };
  };


in
{
  imports = imports ++ nginxImport;
  users = userConfig;

  hardware.graphics = mkIf enableHardwareTranscoding {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };

  containers."${name}" = utils.recursiveMerge [
    additionalContainerConfig
    {
      autoStart = true;
      privateNetwork = true;
      hostAddress = config.host.networking.containerHostIP;
      localAddress = containerIP;

      bindMounts = mkMerge [ bindMounts (mkIf enableHardwareTranscoding { "/dev/dri" = { hostPath = "/dev/dri"; isReadOnly = false; };}) ];
      allowedDevices = optionals (enableHardwareTranscoding) [ { node = "/dev/dri/renderD128"; modifier = "rw"; } { node = "/dev/dri/card0"; modifier = "rw"; } ];

      config = { pkgs, config, lib, ... }: utils.recursiveMerge [
        cfg
        {
          system.stateVersion = stateVersion;
          networking.firewall.allowedTCPPorts = [ containerPort ];
          imports = [ ../../users/root.nix ../../system.nix ] ++ imports ++ pgImport;

          hardware.graphics = mkIf enableHardwareTranscoding {
            enable = true;
            extraPackages = [ pkgs.intel-media-driver ];
          };

          users = userConfig;
        }
      ];
    }
  ];
}
