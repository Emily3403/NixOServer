#!/usr/bin/env bash

# This script installs dependencies such as git, vim, openssh-server, and zfsutils-linux from buster-backports. 
# It also installs the Nix package manager and sets up a RAID-Z on 4 drives.

if [ "$(uname -s)" != "Linux" ]; then
  echo "Error: This script requires a Linux distribution."
  exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

if ! command -v lsb_release &> /dev/null; then
  echo "Error: This script requires the 'lsb-release' package."
  exit 1
fi

if [[ "$(lsb_release -is)" != "Debian" ]]; then
  echo "Error: This script requires a Debian-based Linux distribution."
  exit 1
fi

# Global variables
NUM_DRIVES=4
RAID_LEVEL="raidz1"  # possible values are `stripe`, `mirror`, `raidz1` or any option zfs supports
SWAP_AMOUNT_GB=32
ROOT_POOL_NAME="rpool"
BOOT_POOL_NAME="bpool"

# Install dependencies
apt update
apt install -y git vim openssh-server

# Modify sources.list file
sed -i '/security.debian.org/s/$/ bullseye-security/' /etc/apt/sources.list
sed -i '/deb.debian.org/s/$/ bullseye-updates/' /etc/apt/sources.list
sed -i '/deb.debian.org/s/$/ bullseye-backports/' /etc/apt/sources.list

# Install zfsutils-linux from buster-backports
apt install -y -t buster-backports zfsutils-linux

# Add your script code here

