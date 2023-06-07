#!/usr/bin/env bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

set -e
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/utils.sh"

check_variables GIT_EMAIL GIT_UNAME

# Setup my personal fish shell
mkdir -p "$HOME/.config/fish"
wget https://raw.githubusercontent.com/Emily3403/configAndDotfiles/main/roles/shell/tasks/dotfiles/fish/config.fish -O "$HOME/.config/fish/config.fish"

# Setup git identity
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_UNAME"

# Due to the nature of this setup the NixOS Repo will always be one commit ahead. So make rebase the default strategy.
git config -C "$SCRIPT_DIR" pull.rebase true

# Move and symlink the Nix directory
rm -rf /etc/nixos/.git
rm -rf "$SCRIPT_DIR/../NixDotfiles"
mv /etc/nixos "$SCRIPT_DIR/../NixDotfiles"
ln -s "$SCRIPT_DIR/../NixDotfiles" /etc/nixos

# Commit the changes and rebuild nix
git -C "$SCRIPT_DIR" add -A
git -C "$SCRIPT_DIR" commit -m "Replace placeholders"

# Setup directories needed for installation
mkdir -p /database/postgresql
mkdir -p /database/mysql

chown -R postgres /database/postgresql
chown -R mysql /database/mysql


nixos-rebuild switch
