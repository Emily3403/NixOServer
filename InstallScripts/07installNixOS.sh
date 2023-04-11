#!/usr/bin/env bash

# Get the Nix package manager
curl -L https://nixos.org/nix/install | sh
#source ~/.nix-profile/etc/profile.d/nix.sh

# https://github.com/elitak/nixos-infect
# https://github.com/elitak/nixos-infect/blob/f5da2577ddc924c0ee725fe9729cbf32b3f44808/nixos-infect

# Fetch the latest NixOS channel:
#nix-channel --add https://nixos.org/channels/nixos-22.02 nixos
#nix-channel --update

#nixos-install --no-root-passwd --root /mnt
