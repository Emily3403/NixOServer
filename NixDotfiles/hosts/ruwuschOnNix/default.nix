# Services that should exist:
# - Jellyfin
# - Transmission-openvpn (docker)  (4TB – 8TB)
# - openvpn compatible vpn
#    - Bonus: Able to use mulvad
# - Some form of cloud, probably Nextcloud  (4TB)
#   - WebDAV, different Users, Calendar, Version control
#   - Client _has_ to be able to check for metered connection
# - No central identity management
# - isisdl compressed videos    (2TB)


{ config, pkgs, pkgs-unstable, lib, inputs, modulesPath, ... }: {
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
  ];

  boot.kernelParams = [
    "zfs.zfs_arc_max=68719476736"
    "zfs.zfs_arc_min=12884901888"
    "zfs.zfs_arc_meta_limit=12884901888"
  ];

  networking = {
    hostName = "ruwuschOnNix";
    hostId = "8425e349";
  };
  time.timeZone = "Europe/Berlin";

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # import preconfigured profiles
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    # (modulesPath + "/profiles/hardened.nix")
    # (modulesPath + "/profiles/qemu-guest.nix")
  ];
}
