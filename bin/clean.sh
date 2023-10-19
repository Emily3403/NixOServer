#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR"/../InstallScripts/00diskSetup.sh

sudo umount -R /mnt || true
sudo zpool destroy bpool || true
sudo zpool destroy rpool || true
sudo wipefs --all "${DRIVES[@]}"

sync && udevadm settle
