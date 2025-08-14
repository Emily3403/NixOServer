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

        kernelParams = mkOption {
          description = "Parameters added to the kernel command line";
          type = types.listOf types.str;
          default = [ "ip=dhcp" ];
        };

        initrdAdditionalKernelModules = mkOption {
          description = "Additional kernel modules to load for initrd";
          type = types.listOf types.str;
          default = [ ];
        };

        authorizedKeys = mkOption {
          type = types.listOf types.str;
          default = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAzQFMYrSvjGtzcOUbR1YHawaPMCBDnO4yRKsV7WHkg emily" ];
        };

        zfs = {
          autoSnapshot = {
            enable = mkOption {
              default = true;
              type = types.bool;
              description = "Enable zfs-auto-snapshot";
            };

            quarterHourly  = mkOption {
              default = 0;
              type = types.int;
              description = "Number of 15min auto-snapshots that you wish to keep.";
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

          arc = {
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

        networking = {
          domainName = mkOption {
            type = types.str;
            description = "Domain name to be used";
            default = "ruwusch.de";
          };

          monitoringDomain = mkOption {
            type = types.str;
            description = "fqdn to be used for monitoring the host";
            default = "${config.networking.hostName}.status.${config.host.networking.domainName}";
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


  config = {
    zfs-root.boot = {
      bootDevices = config.host.bootDevices;
      luks.enable = config.host.zfs.encrypted;
      sshUnlock = mkIf config.host.zfs.encrypted {
        enable = true;
        authorizedKeys = config.host.authorizedKeys;
      };
    };

    boot.zfs.forceImportRoot = false;
    powerManagement.cpuFreqGovernor = "performance";

    services.zfs = {
      autoSnapshot = {
        enable = config.host.zfs.autoSnapshot.enable;
        flags = "-k -p --utc";

        frequent = config.host.zfs.autoSnapshot.quarterHourly;
        hourly = config.host.zfs.autoSnapshot.hourly;
        daily = config.host.zfs.autoSnapshot.daily;
        weekly = config.host.zfs.autoSnapshot.weekly;
        monthly = config.host.zfs.autoSnapshot.monthly;
      };

      autoScrub = {
        enable = config.host.zfs.scrub;
        interval = "Sun *-*-01..07 02:00:00"; # Always run on the first Sunday in the month
        randomizedDelaySec = "1h";
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
    ] ++ config.host.initrdAdditionalKernelModules;

    time.timeZone = config.host.networking.timeZone;

    networking = {
      hostName = config.host.name;
      hostId = config.host.id;

      firewall = {
        enable = true;
        allowedTCPPorts = [ 22 80 443 ];
      };
    };
  };
}
