#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"
check_variables DRIVES RAID_LEVEL

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

if [ "$NUM_HOT_SPARES" -gt 0 ]; then
    check_variables HOT_SPARES
    spare_bpool="spare $(convert_dev_names_to_cryptsetup_name "part2" "${HOT_SPARES[@]}")"
    spare_rpool="spare $(convert_dev_names_to_cryptsetup_name "part3" "${HOT_SPARES[@]}")"
else
    spare_bpool=""
    spare_rpool=""
fi



# Initialize an empty array for storing groups of drives
bpool_grouped_drives=()
rpool_grouped_drives=()

# Loop through DRIVES and split into groups
for ((i = 0; i < ${#DRIVES[@]}; i += NUM_DRIVES)); do
    bpool_grouped_drives+=("$RAID_LEVEL")
    rpool_grouped_drives+=("$RAID_LEVEL")

    # Extract a sub-array of size NUM_DRIVES
    group=("${DRIVES[@]:i:NUM_DRIVES}")
    for drive in "${group[@]}"; do
        # Convert the drive into a full path
        bpool_grouped_drives+=("${drive[*]/%/-part2}")  # Don't encrypt the boot pool

        if [[ -n "$LUKS_PASSWORD" ]]; then
            rpool_grouped_drives+=("$(convert_dev_names_to_cryptsetup_name "part3" "$drive")")
        else
            rpool_grouped_drives+=("${drive[*]/%/-part3}")
        fi
    done

done


echo -e "\n\nCreating boot pool ..."

# TODO: Add option to force create if normal create fails
zpool create -f \
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
    bpool \
    "${bpool_grouped_drives[@]/#/}" \
    $spare_bpool  # Splitting here is important, otherwise the array will be treated as a single element

check_zpool_status bpool
echo -e "\nCreating root pool ..."

zpool create -f \
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
    rpool \
    "${rpool_grouped_drives[@]/#/}" \
    $spare_rpool  # Splitting here is important, otherwise the array will be treated as a single element

check_zpool_status rpool

zfs create -o canmount=off -o mountpoint=none rpool/nixos
zfs create -o mountpoint=legacy rpool/nixos/root
zfs create -o mountpoint=legacy rpool/nixos/var
zfs create -o mountpoint=legacy rpool/nixos/var/lib
zfs create -o mountpoint=legacy rpool/nixos/var/log
zfs create -o mountpoint=legacy rpool/nixos/home -o com.sun:auto-snapshot=false  # Disable auto-snapshotting of user-data as my home directories contain backups and they do their own versioning

zfs create -o mountpoint=none bpool/nixos
zfs create -o mountpoint=legacy bpool/nixos/root
zfs create -o mountpoint=legacy rpool/nixos/empty

mount -t zfs rpool/nixos/root /mnt/
mkdir /mnt/home
mkdir /mnt/boot
mount -t zfs rpool/nixos/home /mnt/home
mount -t zfs bpool/nixos/root /mnt/boot

zfs snapshot rpool/nixos/empty@start

for disk in "${DRIVES[@]}"; do
    mkdir -p /mnt/boot/efis/"${disk##*/}"-part1
    mount -t vfat -o iocharset=iso8859-1 "$disk"-part1 /mnt/boot/efis/"${disk##*/}"-part1
done
