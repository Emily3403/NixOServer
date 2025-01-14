{ config, lib, pkgs, ... }:

let
  cfg = config.zfs-root.boot;
  hcfg = config.host;
  inherit (lib) mkIf types mkDefault mkOption mkMerge strings;
  inherit (builtins) head toString map tail;
in
{
  options.zfs-root.boot = {
    enable = mkOption {
      description = "Enable root on ZFS support";
      type = types.bool;
      default = true;
    };

    luks.enable = mkOption {
      description = "Use luks encryption";
      type = types.bool;
      default = false;
    };

    devNodes = mkOption {
      description = "Specify where to discover ZFS pools";
      type = types.str;
      apply = x:
        assert (strings.hasSuffix "/" x
          || abort "devNodes '${x}' must have trailing slash!");
        x;
      default = "/dev/disk/by-id/";
    };

    bootDevices = mkOption {
      description = "Specify boot devices";
      type = types.nonEmptyListOf types.str;
    };

    removableEfi = mkOption {
      description = "install bootloader to fallback location";
      type = types.bool;
      default = true;
    };

    partitionScheme = mkOption {
      default = {
        efiBoot = "-part1";
        bootPool = "-part2";
        rootPool = "-part3";
        swap = "-part4";
        biosBoot = "-part5";
      };
      description = "Describe on disk partitions";
      type = types.attrsOf types.str;
    };

    sshUnlock = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      authorizedKeys = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };
  };

  config = mkIf (cfg.enable) (mkMerge [
    {
      zfs-root.fileSystems.datasets = {
        "bpool/root" = "/boot";
        "rpool/root" = "/";
        "rpool/data" = "/data";
        "rpool/home" = "/home";
      };
    }

    (mkIf cfg.luks.enable {
      boot.initrd.luks.devices = mkMerge (map
        (diskName: { "luks-${diskName}${cfg.partitionScheme.rootPool}" = {
            device = (cfg.devNodes + diskName + cfg.partitionScheme.rootPool);
            allowDiscards = true;
            bypassWorkqueues = true;
          };
        }) cfg.bootDevices);
    })

    {
      zfs-root.fileSystems = {
        efiSystemPartitions = (map (diskName: diskName + cfg.partitionScheme.efiBoot) (cfg.bootDevices ++ hcfg.additionalBootLoaderDevices));
        swapPartitions = (map (diskName: diskName + cfg.partitionScheme.swap) cfg.bootDevices);
      };

      boot = {
        supportedFilesystems.zfs = true;

        zfs = {
          devNodes = cfg.devNodes;
          forceImportRoot = mkDefault false;
        };

        loader = {
          generationsDir.copyKernels = true;

          efi = {
            canTouchEfiVariables = (!cfg.removableEfi);
            efiSysMountPoint = ("/boot/efis/" + (head cfg.bootDevices) + cfg.partitionScheme.efiBoot);
          };

          grub = {
            enable = true;
            devices = (map (diskName: cfg.devNodes + diskName) (cfg.bootDevices ++ hcfg.additionalBootLoaderDevices));
            efiInstallAsRemovable = cfg.removableEfi;
            copyKernels = true;
            efiSupport = true;
            zfsSupport = true;
            extraInstallCommands = (toString (map (diskName: ''
                set -x
                ${pkgs.coreutils-full}/bin/cp -r ${config.boot.loader.efi.efiSysMountPoint}/EFI /boot/efis/${diskName}${cfg.partitionScheme.efiBoot}
                set +x
              '') ((tail cfg.bootDevices) ++ hcfg.additionalBootLoaderDevices)));
          };
        };
      };
    }

    (mkIf cfg.sshUnlock.enable {
      boot = {
        kernelParams = config.host.kernelParams;
        initrd = {
          availableKernelModules = config.host.initrdAdditionalKernelModules;

          network = {
            enable = true;

            ssh = {
              enable = true;
              hostKeys = [
                "/etc/ssh/ssh_host_ed25519_key"
              ];
              authorizedKeys = cfg.sshUnlock.authorizedKeys;
              shell = "/bin/cryptsetup-askpass";
            };
          };
        };
      };
    })
  ]);
}
