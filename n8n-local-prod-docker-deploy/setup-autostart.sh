#!/bin/bash

# Create a LaunchAgent to start n8n automatically on login
# This script should be run as the user who will run n8n

# Get the current user's home directory
USER_HOME="$HOME"
N8N_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create LaunchAgent directory if it doesn't exist
mkdir -p "$USER_HOME/Library/LaunchAgents"

# Create the plist file
cat > "$USER_HOME/Library/LaunchAgents/com.n8n.autostart.plist" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.n8n.autostart</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/docker</string>
        <string>compose</string>
        <string>-f</string>
        <string>${N8N_DIR}/docker-compose.yaml</string>
        <string>up</string>
        <string>-d</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>WorkingDirectory</key>
    <string>${N8N_DIR}</string>
    <key>StandardErrorPath</key>
    <string>${N8N_DIR}/logs/n8n-launcher-error.log</string>
    <key>StandardOutPath</key>
    <string>${N8N_DIR}/logs/n8n-launcher-output.log</string>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOL

# Set permissions
chmod 644 "$USER_HOME/Library/LaunchAgents/com.n8n.autostart.plist"

# Load the launch agent
launchctl load "$USER_HOME/Library/LaunchAgents/com.n8n.autostart.plist"

echo "n8n autostart has been configured successfully."
echo "n8n will now start automatically when you log in."
echo "To disable autostart, run: launchctl unload ~/Library/LaunchAgents/com.n8n.autostart.plist"

# Create a watchdog script to ensure n8n stays running
cat > "$N8N_DIR/n8n-watchdog.sh" << EOL
#!/bin/bash

# Check if n8n containers are running, restart if not
if ! docker ps | grep -q n8n-n8n-1; then
  echo "n8n container is not running. Restarting..."
  cd "${N8N_DIR}" && docker compose up -d
fi

# Check if nginx container is running, restart if not
if ! docker ps | grep -q n8n-nginx-1; then
  echo "nginx container is not running. Restarting..."
  cd "${N8N_DIR}" && docker compose up -d nginx
fi
EOL

chmod +x "$N8N_DIR/n8n-watchdog.sh"

# Create a LaunchAgent for the watchdog
cat > "$USER_HOME/Library/LaunchAgents/com.n8n.watchdog.plist" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.n8n.watchdog</string>
    <key>ProgramArguments</key>
    <array>
        <string>${N8N_DIR}/n8n-watchdog.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>StandardErrorPath</key>
    <string>${N8N_DIR}/logs/n8n-watchdog-error.log</string>
    <key>StandardOutPath</key>
    <string>${N8N_DIR}/logs/n8n-watchdog-output.log</string>
</dict>
</plist>
EOL

chmod 644 "$USER_HOME/Library/LaunchAgents/com.n8n.watchdog.plist"
launchctl load "$USER_HOME/Library/LaunchAgents/com.n8n.watchdog.plist"

echo "n8n watchdog has been configured. It will check every 5 minutes if n8n is running."
echo "To disable the watchdog, run: launchctl unload ~/Library/LaunchAgents/com.n8n.watchdog.plist"
