# Installation

The installation is very streamlined (for a Debian installation):

```
curl https://raw.githubusercontent.com/Emily3403/NixOServer/main/BootstrapScripts/Debian.sh | sudo sh
```

It is recommended to clean the drives before the installation procedure:

```
sudo ./NixOServer/bin/clean.sh
```

Afterward, all the dependencies to install are set up. Next, simply install NixOS with the following command

```
sudo ./NixOServer/bin/install.sh
```

This will read the configuration from `NixOServer/bin/config.sh` and create a ZFS Raid specified by `$RAID_LEVEL` with the number of drives specified by `$NUM_DRIVES`.

Additionally, the script will install NixOS with the configuration specified in the `NixOServer/NixDotfiles` directory.

# Credit

This installation procedure is heavily inspired by [this](https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS/2-system-installation.html) guide.

The `NixDotfiles` are inspired by [this](https://github.com/ne9z/dotfiles-flake) repository.


# TODO

- [ ] How to get a string secret from agenix to the config (Keycloak.initialAdminPassword)
