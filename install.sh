#!/usr/bin/env bash

# This script installs dependencies such as git, vim, openssh-server, and zfsutils-linux from buster-backports. 
# It also installs the Nix package manager and sets up a RAID-Z on 4 drives.

if [ "$(uname -s)" != "Linux" ]; then
  echo "Error: This script requires a Linux distribution."
  exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

if ! command -v lsb_release &> /dev/null; then
  echo "Error: This script requires the 'lsb-release' package."
  exit 1
fi

if [[ "$(lsb_release -is)" != "Debian" ]]; then
  echo "Error: This script requires a Debian-based Linux distribution."
  exit 1
fi

# Global variables
NUM_DRIVES=4
RAID_LEVEL="raidz1"  # possible values are `stripe`, `mirror`, `raidz1` or any option zfs supports
SWAP_AMOUNT_GB=32
ROOT_POOL_NAME="rpool"
BOOT_POOL_NAME="bpool"

# Install dependencies
apt update
apt install -y git vim openssh-server

# Backup the existing sources.list file
cp /etc/apt/sources.list /etc/apt/sources.list.backup."$(date --iso)"

# Define the repositories
bullseye_updates="deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free"
bullseye_backports="deb http://deb.debian.org/debian/ bullseye-backports main contrib non-free"
bullseye_security="deb http://security.debian.org/debian-security bullseye-security main contrib non-free"

# Add repositories if not already present
grep -qxF "$bullseye_updates" /etc/apt/sources.list || echo "$bullseye_updates" | tee -a /etc/apt/sources.list
grep -qxF "$bullseye_backports" /etc/apt/sources.list || echo "$bullseye_backports" | tee -a /etc/apt/sources.list
grep -qxF "$bullseye_security" /etc/apt/sources.list || echo "$bullseye_security" | tee -a /etc/apt/sources.list

# Update package index
apt-get update

# Install zfsutils-linux from buster-backports
apt install -y -t bullseye-backports zfsutils-linux


# Find all drives using /dev/disk/by-id and store the names in a variable
drive_names=$(find /dev/disk/by-id -type l -not -name "*part*")

# Check if the drives are not mounted
unmounted_drives=()
for drive in $drive_names;
do
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

# Sort drives by size and select the n biggest drives
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
echo "The following drives have been auto-detected. Please verify that they are correct by pressing \"y\""
for drive_id in "${selected_drives[@]}"; do
  device_path=$(readlink -f "$drive_id")
  capacity=$(lsblk -bndo SIZE "$device_path" | numfmt --to=iec)
  echo "$drive_id -> $device_path (Capacity: $capacity)"
done

# Prompt the user for verification
while true; do
  read -rp "Are these drives correct? (y/n): " user_input
  case $user_input in
    [Yy]* ) break;;
    [Nn]* ) echo "Please check the drives manually and rerun the script."; exit 1;;
    * ) echo "Please enter 'y' or 'n'.";;
  esac
done

# Save the drives into an array
drives_array=("${selected_drives[@]}")


