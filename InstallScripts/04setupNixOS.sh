#!/usr/bin/env bash

# https://nixos.org/manual/nixos/stable/index.html#sec-installing-from-other-distro

# Check if the group 'nixbld' exists, if not, create it
if ! getent group nixbld > /dev/null; then
    sudo groupadd -g 30000 nixbld
    sudo useradd -u 30000 -g nixbld -G nixbld nixbld
fi

mkdir -p /root/.config/nix
echo "experimental-features = nix-command flakes
cores = $(nproc)
max-jobs = auto" > /root/.config/nix/nix.conf

# Get the Nix package manager, if it isn't yet installed
if [ ! "$(command -v "nix")" ];
then
    echo -e "\n\nInstalling the Nix Package Manager\n"

    curl -L https://nixos.org/nix/install | sh
    source "$HOME/.nix-profile/etc/profile.d/nix.sh"

    # Fetch the latest NixOS channel:
    nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs
    nix-channel --update

    # Install the install tools
    nix-env -f '<nixpkgs>' -iA nixos-install-tools
fi

echo -e "\n\nInstalling the System!\n"
nixos-install --no-root-password --flake "git+file:///mnt/etc/nixos#${HOST_TO_INSTALL}" --cores 32

umount -R /mnt
zpool export -a

echo -e "\n"

# Prompt the user for verification
while true; do
    read -rp "The installation procedure is now complete. Do you wish to reboot? (y/n): " user_input
    case $user_input in
        [Yy]*) break ;;
        [Nn]*)
            echo "Alright, staying up."
            exit 1
            ;;
        *) echo "Please enter 'y' or 'n'." ;;
    esac
done

reboot
