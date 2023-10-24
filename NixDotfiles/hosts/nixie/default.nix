{ system, pkgs, modules, ... }: {
  inherit pkgs system modules;

  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [ "bootDevices_placeholder" ];
      immutable = false;
      removableEfi = true;

      availableKernelModules = [
        "virtio_pci"
        "virtio_blk"
        "ahci"
        "nvme"
        "uas"
      ];

      kernelParams = [
        "zfs.zfs_arc_max=68719476736" "zfs.zfs_arc_min=12884901888"
        "zfs.zfs_arc_meta_limit=12884901888"
      ];

    };

    networking = {
      hostName = "nixie";
      timeZone = "Europe/Berlin";
      hostId = "abcd1234";
    };
  };

}
