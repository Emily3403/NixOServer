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


{ config, modulesPath, pkgs, lib, ... }: {
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
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMooVZ98Wkne2js4jPgypBlPuxZGxJBu8QEhOdCkSTQj"
        ];
      };
    };
  };

  # This option is discouraged, however in all scenarios we want to import the root anymays as there is no other way of solving the problem
  boot.zfs.forceImportRoot = lib.mkForce true;


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
    hostName = "ruwusch";
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
}
