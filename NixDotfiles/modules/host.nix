{ config, lib, pkgs, ... }:

let
  cfg = config;
  inherit (lib) mkIf types mkDefault mkOption mkMerge strings;
  inherit (builtins) head toString map tail;
in
{
  options.host = mkOption {
    description = "Host configuration";

    type = types.submodule {
      options = {
        name = mkOption {
          description = "Specify the host name";
          type = types.str;
        };

        id = mkOption {
          description = "Specify the host id";
          type = types.str;
        };

        bootDevices = mkOption {
          description = "Specify boot devices";
          type = types.nonEmptyListOf types.str;
        };

        additionalBootLoaderDevices = mkOption {
          description = "Specify additional devices to install a stage 1 bootloader to. Useful if you can't directly boot from your hard drives...";
          type = types.listOf types.str;
          default = [ ];
        };

        additionalKernelModules = mkOption {
          description = "Additional kernel modules to load";
          type = types.listOf types.str;
          default = [ ];
        };

        enableHardwareAcceleration = mkOption {
          description = "Enable hardware acceleration";
          type = types.bool;
          default = false;
        };

        zfs = mkOption {
          description = "ZFS Options (snapshots, ARC, scrubbing)";
          default = null;

          type = types.submodule {
            options = {
              autoSnapshot = mkOption {
                description = "Enable zfs-auto-snapshot";
                default = null;

                type = types.submodule {
                  options = {
                    enable = mkOption {
                      default = false;
                      type = types.bool;
                      description = "Enable zfs-auto-snapshot";
                    };

                    hourly = mkOption {
                      default = 0;
                      type = types.int;
                      description = "Number of hourly auto-snapshots that you wish to keep.";
                    };

                    daily = mkOption {
                      default = 7;
                      type = types.int;
                      description = "Number of daily auto-snapshots that you wish to keep.";
                    };

                    weekly = mkOption {
                      default = 4;
                      type = types.int;
                      description = "Number of weekly auto-snapshots that you wish to keep.";
                    };

                    monthly = mkOption {
                      default = 12;
                      type = types.int;
                      description = "Number of monthly auto-snapshots that you wish to keep.";
                    };
                  };
                };
              };

              arc = mkOption {
                description = "Set the ZFS ARC limits";
                default = null;

                type = types.submodule {
                  options = {
                    minGB = mkOption {
                      default = 4;
                      type = types.int;
                      description = "Minimum size of the ARC in Gigabytes";
                    };

                    maxGB = mkOption {
                      default = 8;
                      type = types.int;
                      description = "Maximum size of the ARC in Gigabytes";
                    };
                  };
                };
              };

              scrub = mkOption {
                description = "Enable ZFS scrubbing";
                type = types.bool;
                default = true;
              };

              metrics = mkOption {
                description = "Enable ZFS metrics";
                type = types.bool;
                default = true;
              };

              encrypted = mkOption {
                description = "Is the ZFS encrypted with LUKS?";
                type = types.bool;
                default = false;
              };
            };
          };
        };

        networking = mkOption {
          description = "Configure networking";
          type = types.submodule {
            options = {

              domainName = mkOption {
                type = types.str;
                description = "Domain name to be used";
                default = "inet.tu-berlin.de";
              };

              containerHostIP = mkOption {
                type = types.str;
                description = "IP address of the container host";
                default = "192.168.7.1";
              };

              timeZone = mkOption {
                type = types.str;
                description = "Timezone";
                default = "Europe/Berlin";
              };

            };
          };
        };
      };
    };
  };


  config = {
    zfs-root.boot = {
      bootDevices = config.host.bootDevices;
      luks.enable = config.host.zfs.encrypted;
      sshUnlock = mkIf config.host.zfs.encrypted {
        enable = true;
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAzQFMYrSvjGtzcOUbR1YHawaPMCBDnO4yRKsV7WHkg emily"
        ];
      };
    };

    boot.zfs.forceImportRoot = false;

    hardware.graphics = mkIf config.host.enableHardwareAcceleration {
      enable = true;
      extraPackages = [ pkgs.intel-media-driver ];
    };

    services.zfs = {
      autoSnapshot = {
        enable = config.host.zfs.autoSnapshot.enable;
        flags = "-k -p --utc";

        frequent = 0;
        hourly = config.host.zfs.autoSnapshot.hourly;
        daily = config.host.zfs.autoSnapshot.daily;
        weekly = config.host.zfs.autoSnapshot.weekly;
        monthly = config.host.zfs.autoSnapshot.monthly;
      };

      autoScrub = {
        enable = config.host.zfs.scrub;
        interval = "Sun *-*-01..07 02:00:00";  # Always run on the first Sunday in the month
        randomizedDelaySec = "6h";
      };
    };


    boot.kernelParams = [
      "zfs_arc_min=${toString (config.host.zfs.arc.minGB * 1073741824)}"
      "zfs_arc_max=${toString (config.host.zfs.arc.maxGB * 1073741824)}"
    ];

    boot.initrd.availableKernelModules = [
      # "Normal" disk Support
      "sd_mod"
      "sr_mod"
      "nvme"
      "ahci"

      # QEMU
      "virtio_pci"
      "virtio_blk"
      "virtio_scsi"
      "virtio_net"

      # USB
      "uas"
      "usb_storage"
      "usbhid"

      # Legacy Server Modules
      "ehci_pci"
      "ata_piix"
      "kvm-intel"
      "xhci_pci"

      # Legacy RAID modules
      "megaraid_sas"
      "hpsa"
    ] ++ config.host.additionalKernelModules;

    time.timeZone = config.host.networking.timeZone;
    services.timesyncd.enable = true;


  };
}
