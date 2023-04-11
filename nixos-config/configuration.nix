# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
    imports =
        [ # Include the results of the hardware scan.
            ./hardware-configuration.nix
        ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.11"; # Did you read the comment?

    nix.settings.experimental-features = [ "nix-command"];
    nixpkgs.config.allowUnfree = true;  # Enable the nixpkgs-unstable channel for a larger package selection.


    # Copy the NixOS configuration file and link it from the resulting system
    # (/run/current-system/configuration.nix). This is useful in case you
    # accidentally delete configuration.nix.
    system.copySystemConfiguration = true;

    # Use the GRUB 2 boot loader.
    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    # boot.loader.grub.efiSupport = true;
    # boot.loader.grub.efiInstallAsRemovable = true;
    # boot.loader.efi.efiSysMountPoint = "/boot/efi";
    # Define on which hard drive you want to install Grub.
    # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
    boot.loader.grub.devices = [
        "/dev/disk/by-id/ata-QEMU_HARDDISK_QM00003-part2"
        "/dev/disk/by-id/ata-QEMU_HARDDISK_QM00005-part2"
        "/dev/disk/by-id/ata-QEMU_HARDDISK_QM00007-part2"
        "/dev/disk/by-id/ata-QEMU_HARDDISK_QM00009-part2"
    ];

    # TODO: Firewall?
    networking = {
        hostName = "ruwushOnNixOS";
        hostId = "c0ffee"; # Set a unique 6-digit hex value
        networkmanager.enable = true;  # Enable Networking
    };

    # Configure Systemd services
    services.openssh = {
        enable = true;
        passwordAuthentication = false;
    };

    # Disable the sudo password for the wheel group.  TODO: Is this a good idea?
    security.sudo.wheelNeedsPassword = false;


    # Set your time zone.
    time.timeZone = "Europe/Berlin";

    # Set the default user account.
    users.users = {
        root = {
            initialHashedPassword = "rootHash_placeholder";
            openssh.authorizedKeys.keys = [ "sshKey_placeholder" ];
        };

        emily = {
            initialHashedPassword = "!";
            isNormalUser = true;
            extraGroups = [ "wheel" ]; # Enable ‘sudo’ for your user.
            uid = 1000;
        };
    };

    programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
    };

    programs.git.enable = true;

    # Select console keymap.
     console = {
       font = "Lat2-Terminus16";
       keyMap = "de-latin1";
       useXkbConfig = true; # use xkbOptions in tty.
     };

    # Packages to be installed
     environment.systemPackages = with pkgs; [
       neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
       vim
       wget
       git
     ];
}
