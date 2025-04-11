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

# Get the project root directory (parent of current directory)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Create directory for certificates
CERT_DIR="${PROJECT_ROOT}/volumes/ssl-certs/$N8N_DOMAIN"
mkdir -p "$CERT_DIR"

# Check if source certificates exist with improved error messages
if [ ! -f "$SSL_CERT_PATH" ]; then
    echo "ERROR: SSL certificate not found at: $SSL_CERT_PATH"
    echo "To generate certificates with Let's Encrypt, run:"
    echo "sudo certbot --nginx -d $N8N_DOMAIN"
    exit 1
fi

if [ ! -f "$SSL_KEY_PATH" ]; then
    echo "ERROR: SSL key not found at: $SSL_KEY_PATH"
    echo "To generate certificates with Let's Encrypt, run:"
    echo "sudo certbot --nginx -d $N8N_DOMAIN"
    exit 1
fi

# Validate certificate expiration
if command -v openssl &> /dev/null; then
    echo "Validating certificate expiration..."
    EXPIRY=$(openssl x509 -enddate -noout -in "$SSL_CERT_PATH" | cut -d= -f2)
    EXPIRY_SECONDS=$(date -j -f "%b %d %H:%M:%S %Y %Z" "$EXPIRY" +%s 2>/dev/null || date -d "$EXPIRY" +%s 2>/dev/null)
    NOW_SECONDS=$(date +%s)
    DAYS_LEFT=$(( ($EXPIRY_SECONDS - $NOW_SECONDS) / 86400 ))

    echo "Certificate expires on: $EXPIRY ($DAYS_LEFT days left)"
    if [ $DAYS_LEFT -lt 30 ]; then
        echo "WARNING: Certificate expires in less than 30 days. Consider renewing."
        echo "To renew with Let's Encrypt: sudo certbot renew"
    fi
fi

# Copy certificates with sudo (required for Let's Encrypt certificates)
echo "Copying SSL certificates (sudo password may be required):"
sudo cp "$SSL_CERT_PATH" "$CERT_DIR/fullchain.pem"
sudo cp "$SSL_KEY_PATH" "$CERT_DIR/privkey.pem"

# Set permissions
echo "Setting appropriate permissions..."
sudo chown $USER:$(id -gn) "$CERT_DIR"/*.pem
chmod 644 "$CERT_DIR"/*.pem

# Verify files were copied successfully
if [ -f "$CERT_DIR/fullchain.pem" ] && [ -f "$CERT_DIR/privkey.pem" ]; then
    echo "SSL certificates prepared successfully at: $CERT_DIR"
    echo "You can now start n8n with: ./setup.sh"
else
    echo "ERROR: Failed to copy SSL certificates to $CERT_DIR"
    exit 1
fi
