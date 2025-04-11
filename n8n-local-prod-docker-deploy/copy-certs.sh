#!/bin/bash

# Copy Let's Encrypt certificates with appropriate permissions for Docker
# This script should be run before starting n8n

# Load environment variables
if [ -f "./.env.private" ]; then
    echo "Loading environment variables from .env.private..."
    source ./.env.private
else
    echo "ERROR: .env.private file not found. Please create it first."
    exit 1
fi

# Check if domain is set
if [ -z "$N8N_DOMAIN" ]; then
    echo "ERROR: N8N_DOMAIN is not set in .env.private"
    exit 1
fi

echo "Preparing SSL certificates for $N8N_DOMAIN..."

# Create directory for certificates
CERT_DIR=~/ssl-certs/$N8N_DOMAIN
mkdir -p $CERT_DIR

# Check if source certificates exist
if [ ! -f "$SSL_CERT_PATH" ] || [ ! -f "$SSL_KEY_PATH" ]; then
    echo "ERROR: SSL certificate files not found at:"
    echo "  $SSL_CERT_PATH"
    echo "  $SSL_KEY_PATH"
    exit 1
fi

# Copy certificates with sudo (required for Let's Encrypt certificates)
echo "Copying SSL certificates (sudo password may be required):"
sudo cp $SSL_CERT_PATH $CERT_DIR/fullchain.pem
sudo cp $SSL_KEY_PATH $CERT_DIR/privkey.pem

# Set permissions
echo "Setting appropriate permissions..."
sudo chown $USER:$(id -gn) $CERT_DIR/*.pem
chmod 644 $CERT_DIR/*.pem

echo "SSL certificates prepared successfully at: $CERT_DIR"
echo "You can now start n8n with: ./setup.sh"
