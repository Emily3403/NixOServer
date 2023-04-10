#!/usr/bin/env bash

ROOT_PASSWORD="grootyroot"


mkdir -p /mnt/etc/nixos/
cp -r "$SCRIPT_DIR"/../NixDotfiles/* /mnt/etc/nixos

curl -o /mnt/etc/nixos/configuration.nix -L \
https://github.com/openzfs/openzfs-docs/raw/master/docs/Getting%20Started/NixOS/Root%20on%20ZFS/configuration.nix

for i in $DISK; do
  sed -i \
  "s|/dev/disk/by-id/|${i%/*}/|" \
  /mnt/etc/nixos/hosts/exampleHost/default.nix
  break
done

diskNames=""
for i in $DISK; do
  diskNames="$diskNames \"${i##*/}\""
done

sed -i "s|\"bootDevices_placeholder\"|$diskNames|g" \
  /mnt/etc/nixos/hosts/exampleHost/default.nix

sed -i "s|\"abcd1234\"|\"$(head -c4 /dev/urandom | od -A none -t x4| sed 's| ||g')\"|g" \
  /mnt/etc/nixos/hosts/exampleHost/default.nix

sed -i "s|\"x86_64-linux\"|\"$(uname -m)-linux\"|g" \
  /mnt/etc/nixos/flake.nix

for i in $DISK; do
  sed -i \
  "s|PLACEHOLDER_FOR_DEV_NODE_PATH|\"${i%/*}/\"|" \
  /mnt/etc/nixos/configuration.nix
  break
done

# Customize configuration to your hardware
diskNames=""
for i in $DISK; do
  diskNames="$diskNames \"${i##*/}\""
done
tee -a /mnt/etc/nixos/machine.nix <<EOF
{
  bootDevices = [ $diskNames ];
}
EOF

# Change password
sed -i \
"s|PLACEHOLDER_FOR_ROOT_PWD_HASH|\""${rootPwd}"\"|" \
/mnt/etc/nixos/configuration.nix
