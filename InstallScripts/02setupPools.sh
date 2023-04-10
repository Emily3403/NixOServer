#!/usr/bin/env bash

check_zpool_status() {
  local pool_name="$1"

  if zpool status "$pool_name" >/dev/null 2>&1; then
    echo "ZFS pool '$pool_name' created successfully with RAIDZ1"
    return 0
  else
    echo "Error: ZFS pool '$pool_name' not found or is unhealthy."
    return 1
  fi
}

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"
check_variables DRIVES

echo "Creating boot pool"
echo "${DRIVES[@]/%/-part2}"

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

echo "Creating root pool"

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


if zpool status "$pool_name" >/dev/null 2>&1; then
  echo "ZFS pool '$pool_name' created successfully with RAIDZ1."
else
    echo "Error: Failed to create ZFS pool '$pool_name'."
fi