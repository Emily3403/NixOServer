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

if ! command -v lsb_release &> /dev/null; then
    echo "Error: This script requires the 'lsb-release' package."
    exit 1
fi

if ! command -v apt > /dev/null 2>&1; then
    echo "Error: This script requires a Linux distribution with the 'apt' package manager."
    exit 1
fi

# Install dependencies
apt update
apt install -y git vim openssh-server

# Backup the existing sources.list file
cp /etc/apt/sources.list /etc/apt/sources.list.backup."$(date --iso)"

# Define the repositories
bullseye_updates="deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free"
bullseye_backports="deb http://deb.debian.org/debian/ bullseye-backports main contrib non-free"
bullseye_security="deb http://security.debian.org/debian-security bullseye-security main contrib non-free"

# Add repositories if not already present
grep -qxF "$bullseye_updates" /etc/apt/sources.list || echo "$bullseye_updates" | tee -a /etc/apt/sources.list
grep -qxF "$bullseye_backports" /etc/apt/sources.list || echo "$bullseye_backports" | tee -a /etc/apt/sources.list
grep -qxF "$bullseye_security" /etc/apt/sources.list || echo "$bullseye_security" | tee -a /etc/apt/sources.list

# Update package index
apt-get update

# Install zfsutils-linux from buster-backports
apt install -y -t bullseye-backports zfsutils-linux

# Get the config
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/config.sh"

echo "HEEEEELP"

# Execute the other scripts

for script in "SCRIPT_DIR"/../InstallScripts/*; do
    # Check if the source file exists before sourcing it
    echo "uwu"
    [ -e "$script" ] || continue
    echo "owo"
    source "$script"
done
