#!/usr/bin/env bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

if [ "$(uname -s)" != "Linux" ]; then
    echo "Error: This script requires a Linux distribution."
    exit 1
fi

# TODO: If lsb_release is not founnd, install it

if [ "$(lsb_release -is)" != "Debian" ]; then
    echo "This script is only for Debian systems."
    exit 1
fi

set -e

# Update package lists and install development dependencies
apt-get update
apt-get install -y git vim neovim openssh-server fish btop

# TODO: Install local configuration
chsh -s /usr/bin/fish "$SUDO_USER"

# Create the .ssh directory and set permissions
su -c 'mkdir -p ~/.ssh; chmod 700 ~/.ssh' "$SUDO_USER"

# Download and install SSH keys
su -c 'curl -sL https://github.com/Emily3403.keys >> ~/.ssh/authorized_keys' "$SUDO_USER"

# Set permissions for the authorized_keys file
su -c 'chmod 600 ~/.ssh/authorized_keys' "$SUDO_USER"

# Start the SSH daemon
systemctl enable ssh
systemctl start ssh

repo_dir="/home/$SUDO_USER/NixOServer"
if [ -d "$repo_dir" ]; then
    git -C "$repo_dir" pull
else
    su -c "git clone https://github.com/Emily3403/NixOServer $repo_dir; git -C $repo_dir config pull.rebase false" "$SUDO_USER"
fi

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

local_ip=$(hostname -I | awk '{print $1}')
echo -e "\n\nDebian bootstrap script completed successfully!\nYou may now run the install.sh script!\n"
echo "My current local IP address is: $local_ip"
