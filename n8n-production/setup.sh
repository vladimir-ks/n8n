#!/bin/bash

# n8n Production Setup Script
# This script initializes the n8n production environment
# Compatible with both local Mac deployment and Render

echo "=== n8n Production Setup ==="
echo ""

# Detect environment
IS_MAC=false
if [[ "$OSTYPE" == "darwin"* ]]; then
    IS_MAC=true
    echo "Detected macOS environment"
else
    echo "Detected non-macOS environment (likely cloud/Render)"
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "Docker is not running. Please start Docker first."
    exit 1
fi

# Get directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Create required directories
echo "Creating required directories..."
mkdir -p logs

# Check if .env file exists
if [ ! -f .env ]; then
    echo "ERROR: .env file not found. Please create it first."
    exit 1
fi

# Update hosts file if needed (Mac only)
if [ "$IS_MAC" = true ]; then
    if ! grep -q "ai.vladks.com" /etc/hosts; then
        echo "Adding ai.vladks.com to /etc/hosts..."
        echo "sudo password may be required:"
        echo "127.0.0.1 ai.vladks.com" | sudo tee -a /etc/hosts
    else
        echo "Hosts file entry for ai.vladks.com already exists."
    fi

    # Remind about Amphetamine (Mac only)
    echo "REMINDER: Ensure Amphetamine is configured to keep your Mac awake."
    echo "You can download it from the App Store if not already installed."
fi

# Check SSL certificates (only in local environment)
if [ "$IS_MAC" = true ] && [ ! -d "/etc/letsencrypt/live/ai.vladks.com" ]; then
    echo "WARNING: SSL certificates not found at /etc/letsencrypt/live/ai.vladks.com"
    echo "You may need to generate them using Let's Encrypt."
    echo "For local development, you can continue without them."
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Start n8n using Docker Compose
echo "Starting n8n services..."
docker-compose down
docker-compose up -d

# Check if services started correctly
if [ "$(docker-compose ps -q | wc -l)" -ne 2 ]; then
    echo "ERROR: Failed to start n8n services. Check docker-compose logs."
    exit 1
fi

echo "n8n services started successfully."

# Mac-specific setup
if [ "$IS_MAC" = true ]; then
    # Ask about setting up autostart
    read -p "Do you want to set up n8n to start automatically on login? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./setup-autostart.sh
    fi

    # Ask about setting up backup schedule
    read -p "Do you want to set up automated daily backups? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./setup-backup-schedule.sh
    fi
else
    echo "Skipping Mac-specific setup steps in non-Mac environment."
fi

echo ""
echo "=== Setup Complete ==="
if [ "$IS_MAC" = true ]; then
    echo "n8n should now be accessible at: https://ai.vladks.com"
else
    echo "n8n should now be accessible at your configured domain"
fi
echo ""
echo "Useful commands:"
echo "- Start: docker-compose up -d"
echo "- Stop: docker-compose down"
echo "- View logs: docker-compose logs -f"
if [ "$IS_MAC" = true ]; then
    echo "- Manual backup: ./backup.sh"
fi
echo ""
echo "For more information, see README.md"
