#!/usr/bin/env bash

# https://nixos.org/manual/nixos/stable/index.html#sec-installing-from-other-distro

# Check if the group 'nixbld' exists, if not, create it
if ! getent group nixbld >/dev/null; then
    sudo groupadd -g 30000 nixbld
    sudo useradd -u 30000 -g nixbld -G nixbld nixbld
fi

# Get the Nix package manager
curl -L https://nixos.org/nix/install | sh
source "$HOME/.nix-profile/etc/profile.d/nix.sh"

# Fetch the latest NixOS channel:
nix-channel --add https://nixos.org/channels/nixos-22.11 nixpkgs
nix-channel --update

# Install the install tools
nix-env -f '<nixpkgs>' -iA nixos-install-tools

#nixos-install --no-root-passwd --root /mnt
