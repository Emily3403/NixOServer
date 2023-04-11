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

echo "Creating boot pool"
echo "${DRIVES[@]/%/-part2}"

# TODO: Maybe change the raid level to mirror in order to boot off of it
zpool create -f \
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

zpool create -f \
    -o ashift=12 \
    -o autotrim=on \
    -R /mnt \
    -O acltype=posixacl \
    -O canmount=noauto \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=/ \
    "$ROOT_POOL_NAME" \
    "$RAID_LEVEL" \
    "${DRIVES[@]/%/-part3}"

check_zpool_status "$ROOT_POOL_NAME"

zfs create \
    -o canmount=off \
    -o mountpoint=none \
    "$ROOT_POOL_NAME"/nixos

