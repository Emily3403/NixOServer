#!/usr/bin/env bash

sudo umount /mnt/boot/efis/ata-QEMU_HARDDISK_QM0000* /mnt/boot /mnt/home /mnt

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR"/../InstallScripts/00diskSetup.sh

#sudo umount "${DRIVES[@]}" || true

sudo zpool destroy bpool || true
sudo zpool destroy rpool || true
sudo wipefs --all "${DRIVES[@]}"

sync && udevadm settle
