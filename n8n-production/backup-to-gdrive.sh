#!/bin/bash

# n8n Backup to Google Drive Script
# This script backs up your n8n data to Google Drive using rclone

# Check if rclone is installed
if ! command -v rclone &> /dev/null; then
    echo "rclone is not installed. Please install it first."
    echo "Visit https://rclone.org/install/ for instructions."
    exit 1
fi

# Check if rclone config exists for gdrive
if ! rclone listremotes | grep -q "gdrive:"; then
    echo "Google Drive remote 'gdrive' not configured in rclone."
    echo "Please run 'rclone config' and set up a remote with the following:"
    echo "1. Type: Google Drive"
    echo "2. Name: gdrive"
    echo "3. Follow the prompts to authenticate"
    exit 1
fi

# Sync the backup directory to Google Drive
# Using rclone with the user@example.com configuration
BACKUP_DIR="$HOME/n8n-backups"
GDRIVE_FOLDER="n8n-backups"

# Ensure backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Backup directory $BACKUP_DIR does not exist."
    echo "Please create it or run a backup first."
    exit 1
fi

echo "Starting sync from $BACKUP_DIR to Google Drive folder $GDRIVE_FOLDER..."

# Sync to Google Drive
rclone sync "$BACKUP_DIR" "gdrive:$GDRIVE_FOLDER" \
    --progress \
    --update \
    --transfers 4 \
    --checkers 8

echo "Sync completed!"
