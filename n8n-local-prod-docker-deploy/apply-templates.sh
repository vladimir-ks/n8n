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

# Critical variables check - these are essential for n8n to function properly
CRITICAL_VARS=(
    "N8N_ENCRYPTION_KEY"
)

# Required variables check - these are needed for the templates
REQUIRED_VARS=(
    "N8N_DOMAIN"
    "N8N_PORT"
    "N8N_PROTOCOL"
    "N8N_DATA_DIR"
    "SSL_CERTS_DIR"
    "SSL_CERT_PATH"
    "SSL_KEY_PATH"
    "HOST_IP"
    "N8N_CPU_LIMIT"
    "N8N_MEMORY_LIMIT"
    "N8N_CPU_RESERVATION"
    "N8N_MEMORY_RESERVATION"
    "NGINX_CPU_LIMIT"
    "NGINX_MEMORY_LIMIT"
    "NGINX_CPU_RESERVATION"
    "NGINX_MEMORY_RESERVATION"
)

# Check if private environment file exists in current directory or parent directory
if [ -f ".env.private" ]; then
    ENV_PRIVATE_PATH=".env.private"
    echo -e "${GREEN}Found .env.private in the current directory.${NC}"
elif [ -f "../.env.private" ]; then
    ENV_PRIVATE_PATH="../.env.private"
    echo -e "${GREEN}Found .env.private in the parent directory.${NC}"
else
    echo -e "${YELLOW}Private environment file (.env.private) not found.${NC}"
    echo "Would you like to create it now based on the example? (y/n)"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Check if example exists in current or parent directory
        if [ -f ".env.private.example" ]; then
            cp .env.private.example .env.private
            ENV_PRIVATE_PATH=".env.private"
        elif [ -f "../.env.private.example" ]; then
            cp ../.env.private.example ./.env.private
            ENV_PRIVATE_PATH=".env.private"
        else
            echo -e "${RED}Error: .env.private.example file not found in either directory!${NC}"
            exit 1
        fi
        echo -e "${GREEN}Created .env.private from example.${NC}"
        echo -e "${YELLOW}Please edit .env.private now to set your values, then run this script again.${NC}"
        exit 0
    else
        echo -e "${RED}Cannot continue without .env.private file.${NC}"
        exit 1
    fi
fi

# Source private environment variables
echo "Loading environment variables from ${ENV_PRIVATE_PATH}..."
set -a # Automatically export all variables
source "$ENV_PRIVATE_PATH"
set +a # Stop auto-exporting

# Check for missing required variables
MISSING_VARS=0
for VAR in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!VAR}" ]; then
        echo -e "${RED}Error: Required variable $VAR is not set in ${ENV_PRIVATE_PATH}${NC}"
        MISSING_VARS=1
    fi
done

# Check for missing critical variables
for VAR in "${CRITICAL_VARS[@]}"; do
    if [ -z "${!VAR}" ]; then
        echo -e "${RED}ERROR: CRITICAL variable $VAR is not set in ${ENV_PRIVATE_PATH}${NC}"
        echo -e "${RED}This variable is essential for n8n to function properly.${NC}"
        MISSING_VARS=1
    fi
done

if [ $MISSING_VARS -eq 1 ]; then
    echo -e "${RED}Please set all required variables in ${ENV_PRIVATE_PATH} and try again.${NC}"
    exit 1
fi

# Check for proper format of critical variables
if [ "$N8N_ENCRYPTION_KEY" ] && [ ${#N8N_ENCRYPTION_KEY} -lt 10 ]; then
    echo -e "${RED}ERROR: N8N_ENCRYPTION_KEY must be at least 10 characters long for security.${NC}"
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
    export HOST_IP N8N_DOMAIN N8N_PORT N8N_PROTOCOL N8N_DATA_DIR SSL_CERTS_DIR SSL_CERT_PATH SSL_KEY_PATH N8N_ENCRYPTION_KEY
    export N8N_CPU_LIMIT N8N_MEMORY_LIMIT N8N_CPU_RESERVATION N8N_MEMORY_RESERVATION
    export NGINX_CPU_LIMIT NGINX_MEMORY_LIMIT NGINX_CPU_RESERVATION NGINX_MEMORY_RESERVATION
    envsubst < "$template_file" > "$output_file"

    # Check for any remaining unreplaced placeholders
    if grep -q '\${[A-Za-z0-9_]*}' "$output_file"; then
        echo -e "${YELLOW}Warning: Some placeholders were not replaced in $output_file:${NC}"
        grep -o '\${[A-Za-z0-9_]*}' "$output_file" | sort | uniq | while read -r placeholder; do
            var_name=$(echo "$placeholder" | sed 's/\${//;s/}//')
            echo -e "  - $placeholder (variable '$var_name' not defined)"
        done
        echo -e "${RED}Error: Template substitution incomplete. Fix the missing variables above.${NC}"
        return 1
    else
        echo -e "${GREEN}Successfully created:${NC} $output_file"
    fi

    # Set correct permissions
    if [[ "$output_file" == *.sh ]]; then
        chmod +x "$output_file"
        echo -e "${BLUE}Set executable permissions on${NC} $output_file"
    fi

    return 0
}

echo -e "${BLUE}Looking for template files...${NC}"
# Find and process all template files
TEMPLATE_COUNT=0
TEMPLATE_ERRORS=0
while IFS= read -r template_file; do
    process_template "$template_file"
    if [ $? -ne 0 ]; then
        TEMPLATE_ERRORS=$((TEMPLATE_ERRORS + 1))
    fi
    TEMPLATE_COUNT=$((TEMPLATE_COUNT + 1))
done < <(find . -name "*.template" -type f)

if [ $TEMPLATE_COUNT -eq 0 ]; then
    echo -e "${YELLOW}No template files found.${NC}"
    exit 1
fi

if [ $TEMPLATE_ERRORS -gt 0 ]; then
    echo -e "${RED}Template processing completed with $TEMPLATE_ERRORS errors.${NC}"
    echo -e "${RED}Please fix the missing variables in ${ENV_PRIVATE_PATH} and try again.${NC}"
    exit 1
fi

# Validate critical configuration settings
if [ -f ".env" ]; then
    echo -e "${BLUE}Validating critical configuration settings...${NC}"

    # Check N8N_ENDPOINT_REST
    if grep -q "N8N_ENDPOINT_REST=" ".env"; then
        ENDPOINT_REST_VALUE=$(grep "N8N_ENDPOINT_REST=" ".env" | cut -d'=' -f2)
        if [ "$ENDPOINT_REST_VALUE" != "rest" ]; then
            echo -e "${RED}WARNING: N8N_ENDPOINT_REST should be 'rest', found '$ENDPOINT_REST_VALUE'${NC}"
            echo -e "${YELLOW}This may cause API issues with n8n v1.86+${NC}"
        fi
    fi

    # Check for consistency between .env and docker-compose.yaml
    if [ -f "docker-compose.yaml" ]; then
        echo -e "${BLUE}Checking for configuration consistency...${NC}"

        # Example check: N8N_ENCRYPTION_KEY
        ENV_ENCRYPTION_KEY=$(grep "N8N_ENCRYPTION_KEY=" ".env" | cut -d'=' -f2 | sed 's/#.*//g' | tr -d ' ')
        COMPOSE_ENCRYPTION_KEY=$(grep "N8N_ENCRYPTION_KEY=" "docker-compose.yaml" | sed 's/.*N8N_ENCRYPTION_KEY=//;s/[ "]//g')

        if [ "$ENV_ENCRYPTION_KEY" != "$COMPOSE_ENCRYPTION_KEY" ]; then
            echo -e "${YELLOW}Warning: N8N_ENCRYPTION_KEY is different in .env and docker-compose.yaml${NC}"
        fi
    fi
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
echo
echo -e "${BLUE}For detailed information about environment variables and their usage, see:${NC}"
echo "ENVIRONMENT_VARIABLES.md"
