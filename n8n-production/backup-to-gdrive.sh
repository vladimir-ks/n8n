#!/bin/bash

# First, run the regular backup
./backup.sh

# Sync the backup directory to Google Drive
# Using rclone with the user@example.com configuration
BACKUP_DIR="$HOME/n8n-backups"
GDRIVE_FOLDER="n8n-backups"
DATE=$(date +"%Y-%m-%d")

# Check if rclone is installed
if ! command -v rclone &> /dev/null; then
    echo "rclone is not installed. Installing..."
    brew install rclone
fi

# Check if rclone config exists for vladks
if ! rclone listremotes | grep -q "vladks:"; then
    echo "Google Drive remote 'vladks' not configured in rclone."
    echo "Please run 'rclone config' and set up the remote with these settings:"
    echo "1. Select 'New remote'"
    echo "2. Name: vladks"
    echo "3. Type: drive"
    echo "4. client_id: leave blank"
    echo "5. client_secret: leave blank"
    echo "6. scope: drive.file"
    echo "7. root_folder_id: leave blank"
    echo "8. Service Account Credentials: no"
    echo "9. Edit advanced config: no"
    exit 1
fi

# Create log directory if it doesn't exist
mkdir -p "$HOME/n8n-backups/logs"

# Sync to Google Drive
echo "Syncing backups to Google Drive..."
rclone sync "$BACKUP_DIR" "vladks:$GDRIVE_FOLDER" \
    --include "*.tar.gz" \
    --log-file="$HOME/n8n-backups/logs/gdrive-sync-$DATE.log" \
    --log-level INFO

# Check sync status
if [ $? -eq 0 ]; then
    echo "Backup successfully synced to Google Drive"
    echo "Backup location: $GDRIVE_FOLDER"
else
    echo "Error syncing to Google Drive. Check logs at: $HOME/n8n-backups/logs/gdrive-sync-$DATE.log"
fi
