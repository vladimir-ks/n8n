#!/bin/bash

# Set up automated backup schedule for n8n
# This script creates a LaunchAgent to run daily backups

# Get the current user's home directory
USER_HOME="$HOME"
N8N_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create LaunchAgent directory if it doesn't exist
mkdir -p "$USER_HOME/Library/LaunchAgents"

# Create the plist file for daily backups
cat > "$USER_HOME/Library/LaunchAgents/com.n8n.backup.plist" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.n8n.backup</string>
    <key>ProgramArguments</key>
    <array>
        <string>${N8N_DIR}/backup.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardErrorPath</key>
    <string>${N8N_DIR}/logs/backup-error.log</string>
    <key>StandardOutPath</key>
    <string>${N8N_DIR}/logs/backup-output.log</string>
</dict>
</plist>
EOL

# Set permissions
chmod 644 "$USER_HOME/Library/LaunchAgents/com.n8n.backup.plist"

# Load the launch agent
launchctl load "$USER_HOME/Library/LaunchAgents/com.n8n.backup.plist"

echo "n8n backup schedule has been configured successfully."
echo "Backups will run daily at 2:00 AM."
echo "To disable automated backups, run: launchctl unload ~/Library/LaunchAgents/com.n8n.backup.plist"
