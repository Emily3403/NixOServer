#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/utils.sh"
check_variables DRIVES HOST_TO_INSTALL

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

sed -i "s|\"bootDevices_placeholder\"|$diskNames|g" "/mnt/etc/nixos/hosts/$HOST_TO_INSTALL/default.nix"
sed -i "s|\"hostid_placeholder\"|\"$(head -c4 /dev/urandom | od -A none -t x4| sed 's| ||g' || true)\"|g" "/mnt/etc/nixos/hosts/$HOST_TO_INSTALL/default.nix"

# Set the root password
if [ "$ROOT_PASSWORD" = "!" ]; then
    rootHashPwd="!"
else
    check_root_pw
    rootHashPwd=$(echo "$ROOT_PASSWORD" | mkpasswd -m SHA-512 -s)
fi
sed -i "s|rootHash_placeholder|${rootHashPwd}|" "/mnt/etc/nixos/users/root.nix"

SSH_HOST_KEY_LOCATION="/mnt/etc/ssh/ssh_host_ed25519_key"
SSH_ROOT_DIR="/mnt/root/.ssh/"
SSH_ROOT_ID="$SSH_ROOT_DIR/id_ed25519"

if [ -n "$HOST_PRIVATE_SSH_KEY" ];
then
    mkdir -p "$(dirname $SSH_HOST_KEY_LOCATION)"
    echo "$HOST_PRIVATE_SSH_KEY" > "$SSH_HOST_KEY_LOCATION"
    chmod 600 "$SSH_HOST_KEY_LOCATION"
    ssh-keygen -f "$SSH_HOST_KEY_LOCATION" -y > "/mnt/etc/ssh/ssh_host_ed25519_key.pub"
fi

mkdir -p "$SSH_ROOT_DIR"
if [ ! -L "$SSH_ROOT_ID" ] || [ ! -e "$SSH_ROOT_ID" ];
then
    rm -f "$SSH_ROOT_ID"
    ln -s "/etc/ssh/ssh_host_ed25519_key" "$SSH_ROOT_ID"
fi

# Commit the changes the git repository for NixOS
git config --global user.email "$GIT_EMAIL"
git config --global user.name "$GIT_UNAME"

git -C /mnt/etc/nixos init
git -C /mnt/etc/nixos add --all
git -C /mnt/etc/nixos commit -m "Initial Install"
