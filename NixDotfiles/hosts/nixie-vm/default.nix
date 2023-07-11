{ system, pkgs, modules, ... }: {
  inherit pkgs system modules;

  zfs-root = {
    boot = {
      devNodes = "/dev/";
      bootDevices = [ "bootDevices_placeholder" ];
      immutable = false;

      availableKernelModules = [
        # for booting virtual machine
        # with virtio disk controller
        "virtio_pci"
        "virtio_blk"
        # for sata drive
        "ahci"
        # for nvme drive
        "nvme"
        # for external usb drive
        "uas"
        "xen_blkfront"
        "xen_netfront"
      ];

      removableEfi = true;
      kernelParams = [
        "zfs.zfs_arc_max=68719476736" "zfs.zfs_arc_min=12884901888"
        "zfs.zfs_arc_meta_limit=12884901888"
      ];

    };

    networking = {
      hostName = "nixie-vm";
      timeZone = "Europe/Berlin";
      hostId = "d5dabe5e";
    };
  };

}
