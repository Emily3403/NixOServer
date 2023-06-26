#!/usr/bin/env bash

# TODO: Failsafe if /dev/disk/by-id/ does not contain any drives

# Find all drives using /dev/disk/by-id and store the names in a variable
drive_names=$(find /dev/disk/by-id -type l -not -name "*part*")

# Check if the drives are not mounted
unmounted_drives=()
for drive in $drive_names; do
    device_path=$(readlink -f "$drive")

    if ! grep -qs "$device_path" /proc/mounts; then
        unmounted_drives+=("$drive")
    fi
done

# Check if the number of found drives is less than the desired number
if [ "${#unmounted_drives[@]}" -lt "$NUM_DRIVES" ]; then
    echo "Error: Not enough unmounted drives found. Expected: $NUM_DRIVES, found: ${#unmounted_drives[@]}"
    exit 1
fi

# Sort drives by size and select the $NUM_DRIVES biggest drives
selected_drives=()
for device in $(lsblk -lnbdo NAME,SIZE | sort -k2,2nr | awk '{print "/dev/"$1}' | head -n "$NUM_DRIVES"); do
    for drive_id in "${unmounted_drives[@]}"; do
        device_path=$(readlink -f "$drive_id")
        if [ "$device_path" == "$device" ]; then
            selected_drives+=("$drive_id")
            break
        fi
    done
done

# Print the selected drives
echo -e "The following drives have been auto-detected. Please verify that they are correct by pressing \"y\"\n"
for drive_id in "${selected_drives[@]}"; do
    device_path=$(readlink -f "$drive_id")
    capacity=$(lsblk -bndo SIZE "$device_path" | numfmt --to=iec)
    echo "$drive_id -> $device_path (Capacity: $capacity)"
done
echo

# Prompt the user for verification
while true; do
    read -rp "Are these drives correct? (y/n): " user_input
    case $user_input in
        [Yy]*) break ;;
        [Nn]*)
            echo "Please check the drives manually and rerun the script."
            exit 1
            ;;
        *) echo "Please enter 'y' or 'n'." ;;
    esac
done

# Save the drives into an array and export it
#export DRIVES=("${selected_drives[@]}")
export DRIVES=("/dev/xvdb" "/dev/xvdc" "/dev/xvdd")
