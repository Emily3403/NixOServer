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

# Make the CPU faster
echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Update package lists and install development dependencies
apt-get update
apt-get install -y git vim neovim fish btop sudo

# Set up my personal config
mkdir -p "$HOME/.config/fish" "$HOME/.config/btop"
wget --inet4-only https://raw.githubusercontent.com/Emily3403/configAndDotfiles/main/roles/shell/tasks/dotfiles/fish/config.fish -O "$HOME/.config/fish/config.fish"
wget --inet4-only https://raw.githubusercontent.com/Emily3403/configAndDotfiles/main/roles/shell/tasks/dotfiles/btop/btop.conf -O "$HOME/.config/btop/btop.conf"
chsh -s /usr/bin/fish root

# Create the .ssh directory and set permissions
su -c 'mkdir -p ~/.ssh; chmod 700 ~/.ssh' root

# Download and install SSH keys
su -c 'curl -sL https://github.com/Emily3403.keys >> ~/.ssh/authorized_keys' root
su -c 'curl -sL https://github.com/D-Vampire.keys >> ~/.ssh/authorized_keys' root

# Set permissions for the authorized_keys file
su -c 'chmod 600 ~/.ssh/authorized_keys' root

repo_dir="/root/NixOServer"

if [ -d "$repo_dir" ]; then
    git -C "$repo_dir" pull
else
    git clone https://github.com/Emily3403/NixOServer "$repo_dir"; git -C "$repo_dir" config pull.rebase true
fi

local_ip=$(hostname -I | awk '{print $1}')
echo -e "\n\nDebian bootstrap script completed successfully!\nYou may now run the install.sh script!\n"
echo "My current IP address is: $local_ip"
