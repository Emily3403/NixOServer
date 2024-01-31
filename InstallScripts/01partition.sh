#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

check_variables DRIVES SWAP_AMOUNT_GB NUM_DRIVES
EFFECTIVE_SWAP_PER_DRIVE=$((SWAP_AMOUNT_GB / NUM_DRIVES))
RESERVE=1  # 1 GiB reserve

partition_disk () {
    local disk="${1}"
    blkdiscard -f "${disk}" || true

    parted --script --align=optimal  "${disk}" -- \
    mklabel gpt \
    mkpart EFI 2MiB 1GiB \
    mkpart bpool 1GiB 5GiB \
    mkpart rpool 5GiB -$((EFFECTIVE_SWAP_PER_DRIVE + RESERVE))GiB \
    mkpart swap  -$((EFFECTIVE_SWAP_PER_DRIVE + RESERVE))GiB -"${RESERVE}"GiB \
    mkpart BIOS 1MiB 2MiB \
    set 1 esp on \
    set 5 bios_grub on \
    set 5 legacy_boot on

    partprobe "${disk}"
    udevadm settle
}

for disk in "${DRIVES[@]}" "${HOT_SPARES[@]}"; do
    echo -e "\n\nPartitioning $disk\n"

    partition_disk "${disk}"
    # If using LUKS_PASSWORD, setup cryptsetup
    if [[ -n "$LUKS_PASSWORD" ]]; then
        echo -e "\n\nSetting up LUKS on $disk\n"
        printf "%s" "$LUKS_PASSWORD" | cryptsetup luksFormat --type luks2 "${disk}-part3" -
        printf "%s" "$LUKS_PASSWORD" | cryptsetup luksOpen "${disk}-part3" "luks-rpool-${disk##*/}-part3" -
    fi

    sync && udevadm settle

    mkfs.vfat -n EFI "$disk"-part1
    mkswap "$disk"-part4
done
