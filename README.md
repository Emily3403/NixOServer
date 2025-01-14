# NixOServer

A NixOS Server with a very streamlined installation.

The installation-script will create a ZFS filesystem with the RAID level specified in `bin/config.sh`. It is meant to be installed from a separate drive such that all drives, where the server is going to be installed, can be mounted under `/mnt`. This can be achieved by booting a live iso from a USB or by booting the rescue system of Hetzner.

## Installation

Installation is possible from a variety of operating systems:

- Hetzner Rescue
- Debian
- NixOS
- ...

### Prerequisites

#### 1. Ensure `zfs` is installed.

- For the Hetzer Rescue system, install `zfs` by simply typing in the `zfs` command. The installer will do the rest
- For Debian 11, install it with the [BootstrapScript](./BootstrapScripts/Debian-11.sh). For Debian 12, install it with `apt install zfsutils-linux`.

#### 2. Make sure `zfs --version` is the same as in the NixOS.

- As with most software projects, `zfs` is forward-incompatible with minor releases. More details about the versioning scheme can be found [here](https://github.com/openzfs/zfs/blob/master/RELEASES.md).

  This means that a pool created with `zfs` version `2.2` can't be imported from `zfs` version `2.1`. See [the support matrix](https://openzfs.github.io/openzfs-docs/Basic%20Concepts/Feature%20Flags.html#feature-flags-implementation-per-os) for supported features per version.
- Hetzner always pulls the latest zfs release and compiles it from scratch. So, if the version of hetzner is newer than the one on NixOS, the booting *could* fail.

  Now, each `zfs` version only supports a limited kernel range. Because the kernel of the Hetzner rescue system is always very recent, it is possible that the release of `zfs` you would need is not supported by the kernel. What to do?

  The answer is to boot a [NixOS via Kexec](https://github.com/nix-community/nixos-images#kexec-tarballs). [Kexec](https://wiki.archlinux.org/title/kexec) is a system call that lets you load and boot into another kernel from the currently running kernel. So you can essentially boot up a NixOS from the Hetzner rescue system:

```shell
curl -L https://github.com/nix-community/nixos-images/releases/download/nixos-<version>/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz | tar -xzf- -C /root
/root/kexec/run
```

  After a few seconds, you will be able to `ssh` into the NixOS system. Then verify that `zfs --version` is the one you are looking for.

### Installation Procedure

1. Prepare the Environment
   ```shell
   nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs
   nix-channel --update
   nix-shell -p git util-linux vim wget cryptsetup
   ```
2. Get the Repository
   ```
   git clone https://github.com/Emily3403/NixOServer
   cd NixOServer/bin
   ```
3. It is recommended to clean the drives before the installation procedure:
   ```shell
   ./clean.sh
   ```
4. Configure the installation: 
   ```shell
   $EDITOR ./config.sh
   ```
5. Next, if you are planning on using the remote ssh unlock feature, check if the correct ethernet driver is already included in `initrd.availableKernelModules` by executing
   ```shell
   nix-shell -p pciutils --command "lspci -v | grep -iA20 'network\|ethernet' | grep 'Kernel driver in use'"
   ```
6. Make sure to specify the correct boot devices either with `bootDevices_placeholder` or setting them directly in `hosts/{host}/default.nix`.

   Detect them with
    ```shell
   find /dev/disk/by-id -type l -not -name "*part*" -name "wwn*" -exec ls -la {} \;
   ```
7. Now, install the server with
   ```shell
   ./install.sh
   ```
   This will read the configuration from `./config.sh` and create a ZFS Raid specified by `$RAID_LEVEL` with the number of drives specified by `$NUM_DRIVES`.

   Additionally, the script will install NixOS with the configuration specified in the `NixOServer/NixDotfiles` directory.
8. After the installation is complete, you'll have to clone the repository once more and rebuild
   ```shell
   git clone https://github.com/Emily3403/NixOServer
   cd NixOServer/bin
   ./postInstall.sh
   ```

### Useful Shell Commands
To quickly pull changes and attempt a reinstall, use the following
```
git stash && git pull --rebase && git stash pop && echo "y" | ./clean.sh && echo "y" | ./install.sh
```

# Debugging

To see what's going on with your server, go to the support page and select remote console. You will then be able to view the output.


### ZFS Pool can't be imported
This usually is due to an incompatibility in the zfs that installed the pool and the one that is trying to load it. Did you check `zfs --version` on both systems if they are the same?

### ipconfig: no devices to configure
The remote ssh unlock does not work because the correct driver isn't loaded. Have a look at step 5 of the installation.

# Credit

This installation procedure in the `InstallScripts` directory is heavily inspired by [this](https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS) guide.
