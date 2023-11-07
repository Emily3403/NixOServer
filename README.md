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

```shell
git clone https://github.com/Emily3403/NixOServer
cd NixOServer/bin
```

It is recommended to clean the drives before the installation procedure:

```shell
sudo ./clean.sh
```

Next, edit the config to your liking. You might want to edit things like `NUM_DRIVES`, `RAID_LEVEL` or `ROOT_PASSWORD`.

```shell
$EDITOR ./config.sh
```

Now, install the server with

```
sudo ./install.sh
```

This will read the configuration from `./config.sh` and create a ZFS Raid specified by `$RAID_LEVEL` with the number of drives specified by `$NUM_DRIVES`.

Additionally, the script will install NixOS with the configuration specified in the `NixOServer/NixDotfiles` directory.

# Debugging

This installation is meant to provide a very easy way of installing NixOS on a Hetzner Server. However, sometimes life is not that simple.

One big problem with Hetzner, in particular with the Server Auction, is that you have *very little* debug info. In fact, when auctioning servers, you have **no** output available. So you'll have to guess what the errors are and how to fix them.

In order to circumvent this, one can use [VNC](https://wiki.archlinux.de/title/VNC) to get the output of the console. Now, how can one activate VNC if importing the `zpool` fails and no root or boot filesystem can be loaded? [QEMU](https://wiki.archlinux.org/title/QEMU#VNC)!

More specifically, one can execute qemu with VNC and pass the drives (assuming `/dev/sda, ...`) as follows:

```shell
qemu-system-x86_64 -enable-kvm -m 10240 \
-drive file=/dev/sda,format=raw \
-drive file=/dev/sdb,format=raw \
-drive file=/dev/sdc,format=raw \
-boot d -vnc :0,password=on -monitor stdio
```

Then you can have a look at the boot process with 

```shell
vncviewer <ip>
```

# Credit

This installation procedure in the `InstallScripts` directory is heavily inspired by [this](https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS) guide. The `NixDotfiles` directory is inspired by [this](https://github.com/ne9z/dotfiles-flake) repository.
