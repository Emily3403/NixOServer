#!/usr/bin/env bash

BASE_DIR="/data"

for dir in "$BASE_DIR"/*/"postgresql"; do

    echo "Dumping $dir"
    mkdir -p "$dir/backups"
    chown -R postgres:postgres "$dir/backups"

    container_name=$(echo $dir | cut -d '/' -f 3 | tr '[:upper:]' '[:lower:]')
    backup_path="$dir/backups/backup.$(date +%Y-%m-%d_%H:%M:%S).sql"
    if [ "$container_name" = "wiki" ]; then
        container_name="wiki-js"
    fi

    # Check if the container is a Nix-Container or a Podman-Container
    if nixos-container show-ip "$container_name" > /dev/null 2>&1; then
        nixos-container run "$container_name" -- sudo -u postgres pg_dumpall > "$backup_path"
    else
        podman exec --user="postgres" "$container_name-postgres" pg_dumpall > "$backup_path"
    fi

    # Secure the backup
    chown postgres:postgres "$backup_path"

    # Here, instead of using `chmod 600`, we remove the rwx for and the group. This is to prevent the ACLs from being overwritten.
    chmod o-rwx "$backup_path"

    # Remove old backups
    find "$dir/backups" -type f -mtime +3 -name '*.sql' -delete

done
