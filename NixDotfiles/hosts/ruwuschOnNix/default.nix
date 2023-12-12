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


{ config, modulesPath, pkgs, ... }: {
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [ "bootDevices_placeholder" ];
      immutable = false;
      removableEfi = true;
      luks.enable = false;

      sshUnlock = {
        enable = false;
        authorizedKeys = [ ];
      };
    };
  };

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
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  system.stateVersion = "23.11";

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

    # Hetzner Specific
    "ata_piix"
    "kvm-intel"

    # Transmission
    "tun"
  ];

  boot.kernelParams = [
    "zfs.zfs_arc_max=103079215104"
    "zfs.zfs_arc_min=12884901888"
    "zfs.zfs_arc_meta_limit=51539607552"
  ];

  networking = {
    hostName = "ruwuschOnNix";
    hostId = "abcd1234";
  };

  time.timeZone = "Europe/Berlin";

  # import other host-specific things
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./networking.nix
    ./services.nix
  ];
}
