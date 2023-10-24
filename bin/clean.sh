#!/usr/bin/env bash

sudo umount -R /mnt || true

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR"/../InstallScripts/00diskSetup.sh

sudo zpool destroy bpool || true
sudo zpool destroy rpool || true
sudo wipefs --all "${DRIVES[@]}"

sync && udevadm settle
