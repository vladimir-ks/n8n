#!/bin/bash

# n8n backup script
# This script creates a backup of the n8n data directory

# Get the project root directory (parent of current directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source private environment variables
if [ -f "./.env.private" ]; then
    source ./.env.private
elif [ -f "../.env.private" ]; then
    source "../.env.private"
else
    echo "ERROR: .env.private file not found. Using default paths."
    N8N_DATA_DIR="${PROJECT_ROOT}/volumes/n8n-data"
    BACKUP_DIR="${PROJECT_ROOT}/volumes/backups"
fi

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILENAME="n8n_backup_$DATE.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Print start message
echo "Starting n8n backup at $DATE"
echo "Backing up data from $N8N_DATA_DIR to $BACKUP_DIR/$BACKUP_FILENAME"

# Create backup
if [ -d "$N8N_DATA_DIR" ]; then
    tar -czf "$BACKUP_DIR/$BACKUP_FILENAME" -C "$(dirname "$N8N_DATA_DIR")" "$(basename "$N8N_DATA_DIR")"
else
    echo "ERROR: Data directory $N8N_DATA_DIR not found. Backup failed."
    exit 1
fi

# Check if backup was successful
if [ $? -eq 0 ]; then
    echo "Backup completed successfully"
    echo "Backup file: $BACKUP_DIR/$BACKUP_FILENAME"
    echo "Backup size: $(du -h "$BACKUP_DIR/$BACKUP_FILENAME" | cut -f1)"

    # Clean up old backups (keep the 10 most recent)
    echo "Cleaning up old backups..."
    ls -t "$BACKUP_DIR"/n8n_backup_*.tar.gz | tail -n +11 | xargs -I {} rm {} 2>/dev/null
    echo "Kept the 10 most recent backups."
else
    echo "Backup failed!"
fi

# List remaining backups
echo "Current backups:"
ls -lh "$BACKUP_DIR" | grep "n8n_backup_"
