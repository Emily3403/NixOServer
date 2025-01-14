#!/usr/bin/env bash

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

umount -R /mnt || true

for mapping in $(dmsetup ls --target crypt | awk '{print $1}'); do
  cryptsetup close "$mapping"
done

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR"/../InstallScripts/00diskSetup.sh

zpool import -a -f || true
zpool destroy bpool || true
zpool destroy rpool || true
wipefs --all "${DRIVES[@]}"

sync && udevadm settle
