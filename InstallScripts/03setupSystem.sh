#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"
check_variables BOOT_POOL_NAME ROOT_POOL_NAME

zfs create -o mountpoint=legacy "$ROOT_POOL_NAME"/nixos/root
mount -t zfs "$ROOT_POOL_NAME"/nixos/root /mnt/
zfs create -o mountpoint=legacy "$ROOT_POOL_NAME"/nixos/home
mkdir /mnt/home
mount -t zfs "$ROOT_POOL_NAME"/nixos/home /mnt/home
zfs create -o mountpoint=legacy "$ROOT_POOL_NAME"/nixos/var
zfs create -o mountpoint=legacy "$ROOT_POOL_NAME"/nixos/var/lib
zfs create -o mountpoint=legacy "$ROOT_POOL_NAME"/nixos/var/log
zfs create -o mountpoint=none "$BOOT_POOL_NAME"/nixos
zfs create -o mountpoint=legacy "$BOOT_POOL_NAME"/nixos/root
mkdir /mnt/boot
mount -t zfs "$BOOT_POOL_NAME"/nixos/root /mnt/boot
zfs create -o mountpoint=legacy "$ROOT_POOL_NAME"/nixos/empty
zfs snapshot "$ROOT_POOL_NAME"/nixos/empty@start

for disk in "${DISKS[@]}"; do
    mkfs.vfat -n EFI "$disk"-part1
    mkdir -p /mnt/boot/efis/"${disk##*/}"-part1
    mount -t vfat "$disk"-part1 /mnt/boot/efis/"${disk##*/}"-part1
done
