#!/usr/bin/env bash

return

# https://nixos.org/manual/nixos/stable/index.html#sec-installing-from-other-distro

# Get the Nix package manager
curl -L https://nixos.org/nix/install | sh
source "$HOME/.nix-profile/etc/profile.d/nix.sh"

# Fetch the latest NixOS channel:
nix-channel --add https://nixos.org/channels/nixos-22.11 nixpkgs
nix-channel --update

#nixos-install --no-root-passwd --root /mnt
