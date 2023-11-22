#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"
check_variables DRIVES BOOT_POOL_NAME ROOT_POOL_NAME HOST_TO_INSTALL

mkdir -p /mnt/etc/nixos/
cp -r "$SCRIPT_DIR"/../NixDotfiles/* /mnt/etc/nixos

# Customize installation to the hardware
for i in "${DRIVES[@]}"; do
    sed -i \
        "s|/dev/disk/by-id/|${i%/*}/|" \
        "/mnt/etc/nixos/hosts/$HOST_TO_INSTALL/default.nix"
    break
done

diskNames=""
for i in "${DRIVES[@]}"; do
    diskNames="$diskNames \"${i##*/}\""
done

sed -i "s|\"bootDevices_placeholder\"|$diskNames|g" \
    "/mnt/etc/nixos/hosts/$HOST_TO_INSTALL/default.nix"

sed -i "s|\"abcd1234\"|\"$(head -c4 /dev/urandom | od -A none -t x4| sed 's| ||g' || true)\"|g" \
    "/mnt/etc/nixos/hosts/$HOST_TO_INSTALL/default.nix"

sed -i "s|\"x86_64-linux\"|\"$(uname -m)-linux\"|g" \
    "/mnt/etc/nixos/flake.nix"

# Set the password password
rootHashPwd=$(echo "$ROOT_PASSWORD" | mkpasswd -m SHA-512 -s)
sed -i \
    "s|rootHash_placeholder|${rootHashPwd}|" \
    "/mnt/etc/nixos/users/root.nix"

# Change SSH-Key
Emily_Key=$(curl -sL https://github.com/Emily3403.keys)

sed -i \
    "s|\"sshKey_placeholder\"|\"$Emily_Key\"|" \
   "/mnt/etc/nixos/users/root.nix"

SSH_KEY_LOCATION="/mnt/etc/ssh/ssh_host_rsa_key"
if [ -n "$HOST_PRIVATE_SSH_KEY" ];
then
    mkdir -p "$(dirname $SSH_KEY_LOCATION)"
    echo "$HOST_PRIVATE_SSH_KEY" > "$SSH_KEY_LOCATION"
    chmod 600 "$SSH_KEY_LOCATION"
    ssh-keygen -f "$SSH_KEY_LOCATION" -y > "/mnt/etc/ssh/ssh_host_rsa_key.pub"
fi

# Commit the changes the git repository for NixOS
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_UNAME"

git -C /mnt/etc/nixos init
git -C /mnt/etc/nixos add --all
git -C /mnt/etc/nixos commit -m "Initial Install"
