#!/bin/bash

# =========================================
# n8n Template Application Script
# =========================================
# This script processes template files and replaces placeholders
# with values from environment variables.
# =========================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===== n8n Template Application =====${NC}"
echo

# Required variables check
REQUIRED_VARS=(
    "N8N_DOMAIN"
    "N8N_PORT"
    "N8N_PROTOCOL"
    "N8N_DATA_DIR"
    "SSL_CERTS_DIR"
    "SSL_CERT_PATH"
    "SSL_KEY_PATH"
    "N8N_CPU_LIMIT"
    "N8N_MEMORY_LIMIT"
    "N8N_CPU_RESERVATION"
    "N8N_MEMORY_RESERVATION"
    "NGINX_CPU_LIMIT"
    "NGINX_MEMORY_LIMIT"
    "NGINX_CPU_RESERVATION"
    "NGINX_MEMORY_RESERVATION"
    "N8N_ENCRYPTION_KEY"
)

# Check if private environment file exists
if [ ! -f ".env.private" ]; then
    echo -e "${YELLOW}Private environment file (.env.private) not found.${NC}"
    echo "Would you like to create it now based on the example? (y/n)"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ ! -f ".env.private.example" ]; then
            echo -e "${RED}Error: .env.private.example file not found!${NC}"
            exit 1
        fi
        cp .env.private.example .env.private
        echo -e "${GREEN}Created .env.private from example.${NC}"
        echo -e "${YELLOW}Please edit .env.private now to set your values, then run this script again.${NC}"
        exit 0
    else
        echo -e "${RED}Cannot continue without .env.private file.${NC}"
        exit 1
    fi
fi

# Source private environment variables
echo "Loading environment variables from .env.private..."
source .env.private

# Check for missing required variables
MISSING_VARS=0
for VAR in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!VAR}" ]; then
        echo -e "${RED}Error: Required variable $VAR is not set in .env.private${NC}"
        MISSING_VARS=1
    fi
done

if [ $MISSING_VARS -eq 1 ]; then
    echo -e "${RED}Please set all required variables in .env.private and try again.${NC}"
    exit 1
fi

# Process template function with backup
process_template() {
    template_file=$1
    output_file=${template_file%.template}

    echo -e "${BLUE}Processing:${NC} $template_file -> $output_file"

    # Create backup if file exists
    if [ -f "$output_file" ]; then
        backup_file="${output_file}.backup"
        echo -e "${YELLOW}Backing up existing file to:${NC} $backup_file"
        cp "$output_file" "$backup_file"
    fi

    # Use envsubst to replace environment variables in the template
    envsubst < "$template_file" > "$output_file"

    # Check for any remaining unreplaced placeholders
    if grep -q '\${[A-Za-z0-9_]*}' "$output_file"; then
        echo -e "${YELLOW}Warning: Some placeholders were not replaced in $output_file:${NC}"
        grep -o '\${[A-Za-z0-9_]*}' "$output_file" | sort | uniq
    else
        echo -e "${GREEN}Successfully created:${NC} $output_file"
    fi

    # Set correct permissions
    if [[ "$output_file" == *.sh ]]; then
        chmod +x "$output_file"
        echo -e "${BLUE}Set executable permissions on${NC} $output_file"
    fi
}

echo -e "${BLUE}Looking for template files...${NC}"
# Find and process all template files
TEMPLATE_COUNT=0
while IFS= read -r template_file; do
    process_template "$template_file"
    TEMPLATE_COUNT=$((TEMPLATE_COUNT + 1))
done < <(find . -name "*.template" -type f)

if [ $TEMPLATE_COUNT -eq 0 ]; then
    echo -e "${YELLOW}No template files found.${NC}"
    exit 1
fi

echo
echo -e "${GREEN}All templates processed successfully!${NC}"
echo "----------------"
echo -e "${BLUE}Next steps:${NC}"
echo "1. Review the generated files to ensure they look correct"
echo "2. Run ./setup.sh to start your n8n instance"
echo "3. Make any necessary adjustments to the configuration"
echo
echo -e "${YELLOW}Note: Keep your .env.private file secure and do not commit it to version control.${NC}"
