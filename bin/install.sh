#!/usr/bin/env bash

# This script installs dependencies such as git, vim, openssh-server, and zfsutils-linux from buster-backports.
# It also installs the Nix package manager and sets up a RAID-Z on 4 drives.

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

if [ "$(uname -s)" != "Linux" ]; then
    echo "Error: This script requires a Linux distribution."
    exit 1
fi

set -e

# Install dotfiles early on
mkdir -p "$HOME/.config/fish" "$HOME/.config/btop"
wget --inet4-only https://raw.githubusercontent.com/Emily3403/configAndDotfiles/main/roles/shell/tasks/dotfiles/fish/config.fish -O "$HOME/.config/fish/config.fish"
wget --inet4-only https://raw.githubusercontent.com/Emily3403/configAndDotfiles/main/roles/shell/tasks/dotfiles/btop/btop.conf -O "$HOME/.config/btop/btop.conf"

check_dependency() {
    command -v "$1" > /dev/null 2>&1 || {
        echo >&2 "Error: The required command '$1' is not installed. Please install it and try again."
        exit 1
    }
}

# Check for required dependencies
dependencies=("mkpasswd" "lsblk" "blkdiscard" "parted" "udevadm" "mkswap" "zpool" "zfs" "mkfs.vfat")
for dependency in "${dependencies[@]}"; do
    check_dependency "$dependency"
done

# Get the config
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/utils.sh"

check_host_exists

# The fdisk binary in located in `/sbin` ...
export PATH="$PATH:/sbin:/usr/sbin"

# Execute the other scripts
for script in "$SCRIPT_DIR"/../InstallScripts/*; do
    source "$script"
done
