#!/usr/bin/env bash

# https://nixos.org/manual/nixos/stable/index.html#sec-installing-from-other-distro

# Create the necessary groups
sudo groupadd -r -g 30000 nixbld
sudo useradd -r -u 30000 -g nixbld -G nixbld nixbld

# Get the Nix package manager
curl -L https://nixos.org/nix/install | sh
source "$HOME/.nix-profile/etc/profile.d/nix.sh"

# Fetch the latest NixOS channel:
nix-channel --add https://nixos.org/channels/nixos-22.11 nixpkgs
nix-channel --update

# Install the install tools
nix-env -f '<nixpkgs>' -iA nixos-install-tools

#nixos-install --no-root-passwd --root /mnt
