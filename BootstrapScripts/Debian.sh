#!/usr/bin/env bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

if [ "$(uname -s)" != "Linux" ]; then
    echo "Error: This script requires a Linux distribution."
    exit 1
fi

if [ "$(lsb_release -is)" != "Debian" ]; then
    echo "This script is only for Debian systems."
    exit 1
fi

set -e

# Update package lists and install development dependencies
apt-get update
apt-get install -y git vim openssh-server fish

chsh -s /usr/bin/fish "$USER"

# Create the .ssh directory and set permissions
mkdir -p "$USER/.ssh"
chmod 700 "$USER/.ssh"

# Download and install SSH keys
curl -sL https://github.com/Emily3403.keys >> "$USER/.ssh/authorized_keys"
curl -sL https://github.com/D-VAmpire.keys >> "$USER/.ssh/authorized_keys"

# Set permissions for the authorized_keys file
chmod 600 "$USER/.ssh/authorized_keys"

# Start the SSH daemon
systemctl enable ssh
systemctl start ssh

# Clone the repository
git clone https://github.com/Emily3403/NixOServer ~/NixOServer

# Install dependencies for installation
apt install -y gdisk dosfstools whois

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

# TODO: Should this script also start the installer?

echo "Debian bootstrap script completed successfully!"
