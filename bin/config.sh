# Drive Setup
export NUM_DRIVES=4         # The number of drives per vdev
export RAID_LEVEL="raidz1"  # possible values are `stripe`, `mirror`, `raidz1` or any option zfs supports
export NUM_VDEVS=1          # The number of vdevs to add with the same RAID configuration. Typically 1, however 2 is needed for RAID-10
export SWAP_AMOUNT_GB=128
export NUM_HOT_SPARES=0     # The number of hot spares should be included in `NUM_DRIVES`. Set to 0 to disable hot spares.
export ADDITIONAL_EFI_DEVICE=""  # With the /dev/disk/by-id prefix

# Configuration of the system
export LUKS_PASSWORD=""  # Leave blank to disable encryption
export HOST_PRIVATE_SSH_KEY=""  # You may set the private key used for agenix decryption

# Host Setup
export HOST_TO_INSTALL="nixie"
export ROOT_PASSWORD=""
export GIT_EMAIL="seebeckemily3403@gmail.com"
export GIT_UNAME="Emily3403"
