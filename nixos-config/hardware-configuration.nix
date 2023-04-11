# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "rpool/nixos/root";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/nixos/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "bpool/nixos/root";
      fsType = "zfs";
    };

  fileSystems."/boot/efis/ata-QEMU_HARDDISK_QM00003-part1" =
    { device = "/dev/disk/by-uuid/DA92-FCA4";
      fsType = "vfat";
    };

  fileSystems."/boot/efis/ata-QEMU_HARDDISK_QM00005-part1" =
    { device = "/dev/disk/by-uuid/DA93-7CA7";
      fsType = "vfat";
    };

  fileSystems."/boot/efis/ata-QEMU_HARDDISK_QM00007-part1" =
    { device = "/dev/disk/by-uuid/DA93-FE1B";
      fsType = "vfat";
    };

  fileSystems."/boot/efis/ata-QEMU_HARDDISK_QM00009-part1" =
    { device = "/dev/disk/by-uuid/DA94-887D";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
