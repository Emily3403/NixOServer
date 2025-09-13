#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

check_variables DRIVES SWAP_AMOUNT_GB NUM_DRIVES
EFFECTIVE_SWAP_PER_DRIVE=$((SWAP_AMOUNT_GB / NUM_DRIVES))
BPOOL_END=5
SWAP_END=$((BPOOL_END + EFFECTIVE_SWAP_PER_DRIVE))

partition_disk () {
    local disk="${1}"
    blkdiscard -f "${disk}" || true

    parted --script --align=optimal "${disk}" -- \
      mklabel gpt \
      mkpart "BIOS" 1MiB 2MiB \
      mkpart "EFI" 2MiB 1GiB \
      mkpart "bpool" 1GiB ${BPOOL_END}GiB \
      mkpart "swap" ${BPOOL_END}GiB ${SWAP_END}GiB \
      mkpart "rpool" ${SWAP_END}GiB 100% \
      set 1 bios_grub on \
      set 2 esp on

    partprobe "${disk}"
    udevadm settle
}

for disk in "${DRIVES[@]}" "${HOT_SPARES[@]}"; do
    echo -e "\n\nPartitioning $disk\n"

    partition_disk "${disk}"
    # If using LUKS_PASSWORD, setup cryptsetup
    if [[ -n "$LUKS_PASSWORD" ]]; then
        echo -e "\n\nSetting up encryption on $disk-part5\n"
        printf "%s" "$LUKS_PASSWORD" | cryptsetup luksFormat --type luks2 "${disk}-part5" -
        printf "%s" "$LUKS_PASSWORD" | cryptsetup luksOpen "${disk}-part5" "luks-${disk##*/}-part5" -
    fi

    sync && udevadm settle

    mkfs.vfat -n EFI "$disk"-part2
    mkswap "$disk"-part4
done
