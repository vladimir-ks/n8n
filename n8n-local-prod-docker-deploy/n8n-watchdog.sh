#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if n8n containers are running, restart if not
if ! docker ps | grep -q n8n-n8n-1; then
  echo "n8n container is not running. Restarting..."
  cd "$SCRIPT_DIR" && docker compose up -d
fi

# Check if nginx container is running, restart if not
if ! docker ps | grep -q n8n-nginx-1; then
  echo "nginx container is not running. Restarting..."
  cd "$SCRIPT_DIR" && docker compose up -d nginx
fi
