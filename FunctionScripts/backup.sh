#!/usr/bin/env bash

# This script is used to backup all the data on the server from another machine. It may be your laptop, desktop or another server.
# This script will keep daily, weekly, monthly and yearly backups of the data. It will also remove old backups once the limit is reached.

# Note: Make sure you have setup the permissions for the /data directory. You can either log in as root or use the `backup` user.
# Make sure to include the `services/Backup.nix` file and change the `a` to a `A` in the `systemd.tmpfiles.rules` to set the ACLs recursively for the backup user.
# Afterwards, change it back to `a` to avoid spending 5min+ on every rebuild.

# Running this script in a scheduled manner is recommended. You can use `cron` or `systemd` for this purpose.

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SOURCE_DIR="/data"
BACKUP_DIR="${SCRIPT_DIR}"

SSH_HOST="ruwusch"

MAX_DAILY_BACKUPS=30
MAX_WEEKLY_BACKUPS=6
MAX_MONTHLY_BACKUPS=24
MAX_YEARLY_BACKUPS=5

do_daily_backup() {
    backup_dir="${BACKUP_DIR}/daily"
    backup_path="${backup_dir}/$(date +%Y-%m-%d)"
    last_backup="${backup_dir}/last"

    mkdir -p "${backup_path}"
    rsync -a --link-dest="${last_backup}" "${SSH_HOST}:${SOURCE_DIR}/" "${backup_path}"

    # Update the 'current' symlink to point to the latest backup
    ln -nsf "${backup_path}" "${last_backup}"

    # Remove old backups beyond the retention period
    find "${backup_dir}" -maxdepth 1 -mindepth 1 -type d | sort -r | tail -n +"${MAX_DAILY_BACKUPS}" | xargs -d '\n' -r rm -rf --
}

do_daily_backup

# TODO: Error handling
# TODO: Weekly, Monthly, Yearly backups
# TODO: Postgres database backup
