This guide is heavily inspired from [this](https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS/2-system-installation.html) source. 

Preparation is assumed:

```
export DISK="/dev/disk/by-id/... /dev/disk/by-id/..."
export INST_PARTSIZE_SWAP=32  # Swap size in GB
```

The `NixDotfiles` are inspired by [this](https://github.com/ne9z/dotfiles-flake)