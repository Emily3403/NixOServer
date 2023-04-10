#!/usr/bin/env bash

exit

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"

check_variables DRIVES SWAP_AMOUNT_GB
EFFECTIVE_SWAP_PER_DRIVE=$(( SWAP_AMOUNT_GB / NUM_DRIVES ))


for disk in "${DRIVES[@]}"; do

    # wipe flash-based storage device to improve
    # performance.
    # ALL DATA WILL BE LOST
    # blkdiscard -f $disk
    echo $disk

    sgdisk --zap-all $disk

    sgdisk -n1:1M:+1G -t1:EF00 $disk

    sgdisk -n2:0:+4G -t2:BE00 $disk

    sgdisk -n4:0:+${EFFECTIVE_SWAP_PER_DRIVE}G -t4:8200 $disk

    sgdisk -n3:0:0 -t3:BF00 $disk

    sgdisk -a1 -n5:24K:+1000K -t5:EF02 $disk

    sync && udevadm settle

    mkswap "$disk"-part4
done
