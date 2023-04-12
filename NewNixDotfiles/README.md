* Minimal NixOS Root on ZFS configuration
This repo contains a minimal set of configuration needed for
installing NixOS on a computer with ZFS as root filesystem.

Stolen from https://github.com/ne9z/dotfiles-flake

#+begin_src text
.gitignore
LICENSE
configuration.nix   <- configuration shared by all hosts
flake.lock
flake.nix
hosts/exampleHost/default.nix  <- per-host configuration
hosts/exampleHost/sshUnlock.txt
modules/boot/default.nix
modules/default.nix
modules/fileSystems/default.nix
modules/networking/default.nix
modules/users/default.nix
#+end_src

Just enough to get you started.

For a more complete example with bells and whistles, see other
branches of this repo.
