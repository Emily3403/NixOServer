#!/usr/bin/env bash

check_zpool_status() {
    local pool_name="$1"

    if zpool status "$pool_name" > /dev/null 2>&1; then
        echo "ZFS pool '$pool_name' created successfully with $RAID_LEVEL"
        return 0
    else
        echo "Error: ZFS pool '$pool_name' not found or is unhealthy."
        return 1
    fi
}

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"
check_variables DRIVES RAID_LEVEL BOOT_POOL_NAME ROOT_POOL_NAME

echo -e "\n\nCreating boot pool ...\n"

zpool create \
    -o compatibility=grub2 \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=lz4 \
    -O devices=off \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/boot \
    -R /mnt \
    "$BOOT_POOL_NAME" \
    "$RAID_LEVEL" \
    "${DRIVES[@]/%/-part2}"

check_zpool_status "$BOOT_POOL_NAME"

zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/ \
    -R /mnt \
    "$ROOT_POOL_NAME" \
    "$RAID_LEVEL" \
    "${DRIVES[@]/%/-part3}"

check_zpool_status "$ROOT_POOL_NAME"

zfs create \
    -o canmount=off \
    -o mountpoint=none \
    "$ROOT_POOL_NAME"/nixos

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

for disk in "${DRIVES[@]}"; do
    mkdir -p /mnt/boot/efis/"${disk##*/}"-part1
    mount -t vfat -o iocharset=iso8859-1 "$disk"-part1 /mnt/boot/efis/"${disk##*/}"-part1
done
