# Drive Setup
export NUM_DRIVES=3
export RAID_LEVEL="raidz1" # possible values are `stripe`, `mirror`, `raidz1` or any option zfs supports
export ROOT_POOL_NAME="rpool"
export BOOT_POOL_NAME="bpool"
export SWAP_AMOUNT_GB=32

# Host Setup
export HOST_TO_INSTALL="ruwuschOnNix"
export ROOT_PASSWORD="root"
export GIT_EMAIL="uwu@owo.com"
export GIT_UNAME="Emily3403"
export HOST_PRIVATE_SSH_KEY=""  # You may set the private key used for agenix decryption
