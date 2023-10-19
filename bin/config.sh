export NUM_DRIVES=3
export RAID_LEVEL="raidz1" # possible values are `stripe`, `mirror`, `raidz1` or any option zfs supports
export ROOT_POOL_NAME="rpool"
export BOOT_POOL_NAME="bpool"

export HOST_TO_INSTALL="nixie"

export SWAP_AMOUNT_GB=32
export ROOT_PASSWORD="root"

export GIT_EMAIL="uwu@owo.com"
export GIT_UNAME="Emily3403"

# --- DO NOT EDIT ---

# Check if the host actually exists
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
if [[ ! -d "$SCRIPT_DIR/../NixDotfiles/hosts/${HOST_TO_INSTALL}" ]]
then
    echo "ERROR: The specified host does not exist!"
    exit 1
fi