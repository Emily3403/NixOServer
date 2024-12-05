# Services that should exist:
# - Jellyfin
# - Transmission-openvpn (docker)  (4TB – 8TB)
# - openvpn compatible vpn
#    - Bonus: Able to use mulvad
# - Some form of cloud, probably Nextcloud  (4TB)
#   - WebDAV, different Users, Calendar, Version control
#   - Client _has_ to be able to check for metered connection
#   - Stores the data encrypted
# - Central identity management with Keycloak
# - isisdl compressed videos    (2TB)


{ config, modulesPath, pkgs, pkgs-unfree, lib, ... }: {
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [ "bootDevices_placeholder" ];
      removableEfi = true;
      luks.enable = true;

      sshUnlock = {
        enable = true;
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAzQFMYrSvjGtzcOUbR1YHawaPMCBDnO4yRKsV7WHkg emily"
        ];
      };
    };
  };

  # This option is discouraged, however in all scenarios we want to import the root anymays as there is no other way of solving the problem
  boot.zfs.forceImportRoot = false;

  services.zfs = {
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
      weekly = 7; # How many snapshots to keep
      monthly = 48;
    };
  };

  # Hardware accelleration
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };

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

    # Server Specific
    "ehci_pci"
    "ata_piix"
    "uhci_hcd"
    "hpsa"
    "kvm-intel"
  ];

  boot.kernelModules = [ "kv-intel" ];

  boot.kernelParams = [
    "zfs.zfs_arc_max=103079215104"
    "zfs.zfs_arc_min=12884901888"
    "zfs.zfs_arc_meta_limit=51539607552"
  ];

  networking = {
    hostName = "nixie";
    hostId = "abcd1234";
  };

  time.timeZone = "Europe/Berlin";

  # import other host-specific things
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./networking.nix
    ./services.nix
    ./secrets.nix
  ];

  monitoredServices = {
    prometheus = true;
    syncthing = true;
    nextcloud = true;
  };
}
