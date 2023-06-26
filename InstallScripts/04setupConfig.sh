#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"
check_variables DRIVES BOOT_POOL_NAME ROOT_POOL_NAME

mkdir -p /mnt/etc/nixos/
cp -r "$SCRIPT_DIR"/../NixDotfiles/* /mnt/etc/nixos

for i in "${DRIVES[@]}"; do
    sed -i \
        "s|/dev/disk/by-id/|${i%/*}/|" \
        /mnt/etc/nixos/hosts/exampleHost/default.nix
    break
done

diskNames=""
for i in "${DRIVES[@]}"; do
    diskNames="$diskNames \"${i##*/}\""
done

sed -i "s|\"bootDevices_placeholder\"|$diskNames|g" \
    /mnt/etc/nixos/hosts/exampleHost/default.nix

sed -i "s|\"abcd1234\"|\"$(head -c4 /dev/urandom | od -A none -t x4 | sed 's| ||g')\"|g" \
    /mnt/etc/nixos/hosts/exampleHost/default.nix

sed -i "s|\"x86_64-linux\"|\"$(uname -m)-linux\"|g" \
    /mnt/etc/nixos/flake.nix

for i in "${DRIVES[@]}"; do
    sed -i \
        "s|PLACEHOLDER_FOR_DEV_NODE_PATH|\"${i%/*}/\"|" \
        /mnt/etc/nixos/configuration.nix
    break
done

# Customize configuration to your hardware
diskNames=""
for i in "${DRIVES[@]}"; do
    diskNames="$diskNames \"${i##*/}\""
done
tee -a /mnt/etc/nixos/machine.nix << EOF
{
  bootDevices = [ $diskNames ];
}
EOF

# Change password
rootHashPwd=$(echo "$ROOT_PASSWORD" | mkpasswd -m SHA-512 -s)
sed -i \
    "s|rootHash_placeholder|${rootHashPwd}|" \
    /mnt/etc/nixos/configuration.nix

# Change SSH-Key
Emily_Key=$(curl -sL https://github.com/Emily3403.keys)
Carsten_Key=$(curl -sL https://github.com/D-VAmpire.keys)

sed -i \
    "s|\"sshKey_placeholder\"|\"$Emily_Key\"|" \
    /mnt/etc/nixos/configuration.nix
