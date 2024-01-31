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

convert_dev_names_to_cryptsetup_name() {
    local part_name="$1"
    shift
    local dev_names=( "$@" )

    local cryptsetup_names=()
    for dev_name in "${dev_names[@]}"; do
        cryptsetup_names+=( "/dev/mapper/luks-rpool-${dev_name##*/}-$part_name" )
    done

    echo "${cryptsetup_names[@]}"
}

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"
check_variables DRIVES RAID_LEVEL BOOT_POOL_NAME ROOT_POOL_NAME

if [ "$NUM_HOT_SPARES" -gt 0 ]; then
    check_variables HOT_SPARES
    spare_bpool="spare $(convert_dev_names_to_cryptsetup_name "part2" "${HOT_SPARES[@]}")"
    spare_rpool="spare $(convert_dev_names_to_cryptsetup_name "part3" "${HOT_SPARES[@]}")"
else
    spare_bpool=""
    spare_rpool=""
fi

if [[ -n "$LUKS_PASSWORD" ]]; then
    rpool="$(convert_dev_names_to_cryptsetup_name "part3" "${DRIVES[@]}")"
else
    rpool="${DRIVES[*]/%/-part3}"
fi

echo -e "\n\nCreating boot pool ..."

zpool create \
    -o compatibility=grub2 \
    -o ashift=12 \
    -o autotrim=on \
    -O atime=off \
    -O acltype=posixacl \
    -O canmount=off \
    -O compression=lz4 \
    -O devices=off \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O com.sun:auto-snapshot=true \
    -O mountpoint=/boot \
    -R /mnt \
    "$BOOT_POOL_NAME" \
    "$RAID_LEVEL" \
    "${DRIVES[@]/%/-part2}" \
    $spare_bpool  # Splitting here is important, otherwise the array will be treated as a single element

check_zpool_status "$BOOT_POOL_NAME"
echo -e "\nCreating root pool ..."

zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -O acltype=posixacl \
    -O atime=off \
    -O canmount=off \
    -O compression=zstd \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O com.sun:auto-snapshot=true \
    -O mountpoint=/ \
    -R /mnt \
    "$ROOT_POOL_NAME" \
    "$RAID_LEVEL" \
    $rpool \
    $spare_rpool  # Splitting here is important, otherwise the array will be treated as a single element

check_zpool_status "$ROOT_POOL_NAME"

zfs create -o canmount=off -o mountpoint=none "$ROOT_POOL_NAME"/nixos
zfs create -o mountpoint=legacy "$ROOT_POOL_NAME"/nixos/root
zfs create -o mountpoint=legacy "$ROOT_POOL_NAME"/nixos/home
zfs create -o mountpoint=legacy "$ROOT_POOL_NAME"/nixos/var
zfs create -o mountpoint=legacy "$ROOT_POOL_NAME"/nixos/var/lib
zfs create -o mountpoint=legacy "$ROOT_POOL_NAME"/nixos/var/log
zfs create -o mountpoint=none "$BOOT_POOL_NAME"/nixos
zfs create -o mountpoint=legacy "$BOOT_POOL_NAME"/nixos/root
zfs create -o mountpoint=legacy "$ROOT_POOL_NAME"/nixos/empty

echo "Making dirs"

mount -t zfs "$ROOT_POOL_NAME"/nixos/root /mnt/
mkdir /mnt/home
mkdir /mnt/boot
mount -t zfs "$ROOT_POOL_NAME"/nixos/home /mnt/home
mount -t zfs "$BOOT_POOL_NAME"/nixos/root /mnt/boot

zfs snapshot "$ROOT_POOL_NAME"/nixos/empty@start

for disk in "${DRIVES[@]}"; do
    mkdir -p /mnt/boot/efis/"${disk##*/}"-part1
    mount -t vfat -o iocharset=iso8859-1 "$disk"-part1 /mnt/boot/efis/"${disk##*/}"-part1
done
