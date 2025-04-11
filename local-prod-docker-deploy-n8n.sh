#!/bin/bash

# n8n Docker Deployment Launcher
# This script guides users through deploying n8n with Docker

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}     n8n Docker Deployment Tool     ${NC}"
echo -e "${BLUE}=====================================${NC}"
echo

# Check if .env.private exists in the root directory
if [ ! -f ".env.private" ]; then
    echo -e "${YELLOW}No .env.private configuration file found.${NC}"
    echo -e "Would you like to create one based on the example? (y/n)"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp .env.private.example .env.private
        echo -e "${GREEN}Created .env.private from example template.${NC}"
        echo -e "${YELLOW}Please edit .env.private with your specific configuration before continuing.${NC}"
        exit 0
    else
        echo -e "${RED}Configuration file is required for deployment.${NC}"
        exit 1
    fi
fi

# Quick validation of .env.private contents before proceeding
echo -e "${BLUE}Performing basic validation of .env.private...${NC}"

# Source the file to access variables
source .env.private

# Check for HOST_IP which is required for network configuration
if [ -z "$HOST_IP" ]; then
    echo -e "${RED}Error: HOST_IP is not set in .env.private${NC}"
    echo -e "${YELLOW}This is required for proper network configuration.${NC}"
    echo -e "Would you like to detect and set it automatically? (y/n)"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Try to detect local IP
        DETECTED_IP=$(hostname -I | awk '{print $1}')
        if [ -n "$DETECTED_IP" ]; then
            echo -e "${GREEN}Detected IP: $DETECTED_IP${NC}"
            # Add or update HOST_IP in .env.private
            if grep -q "^HOST_IP=" .env.private; then
                # Update existing entry
                sed -i.bak "s/^HOST_IP=.*/HOST_IP=$DETECTED_IP/" .env.private
            else
                # Add new entry
                echo "HOST_IP=$DETECTED_IP" >> .env.private
            fi
            echo -e "${GREEN}Updated .env.private with detected IP.${NC}"
            # Re-source to update the variable
            source .env.private
        else
            echo -e "${RED}Could not detect local IP address automatically.${NC}"
            echo -e "${YELLOW}Please edit .env.private and add HOST_IP manually, then run this script again.${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Please edit .env.private to add HOST_IP, then run this script again.${NC}"
        exit 1
    fi
fi

# Check for essential SSL configuration if using HTTPS
if [ "$N8N_PROTOCOL" = "https" ] && { [ -z "$SSL_CERT_PATH" ] || [ -z "$SSL_KEY_PATH" ]; }; then
    echo -e "${RED}Warning: HTTPS protocol selected but SSL certificate paths are not properly configured.${NC}"
    echo -e "${YELLOW}Please ensure SSL_CERT_PATH and SSL_KEY_PATH are set correctly in .env.private${NC}"
fi

# Change to deployment directory
DEPLOY_DIR="n8n-local-prod-docker-deploy"
if [ ! -d "$DEPLOY_DIR" ]; then
    echo -e "${RED}Error: Deployment directory '${DEPLOY_DIR}' not found!${NC}"
    exit 1
fi

echo -e "${BLUE}Starting deployment process from ${DEPLOY_DIR}...${NC}"
cd "$DEPLOY_DIR"

# Apply templates
if [ -f "./apply-templates.sh" ]; then
    echo -e "${BLUE}Applying configuration templates...${NC}"
    ./apply-templates.sh
else
    echo -e "${RED}Error: apply-templates.sh not found in ${DEPLOY_DIR}${NC}"
    exit 1
fi

# Run setup if templates were successfully applied
if [ $? -eq 0 ]; then
    if [ -f "./setup.sh" ]; then
        echo -e "${BLUE}Running setup...${NC}"
        ./setup.sh
    else
        echo -e "${RED}Error: setup.sh not found in ${DEPLOY_DIR}${NC}"
        exit 1
    fi
else
    echo -e "${RED}Template application failed, aborting setup.${NC}"
    exit 1
fi

echo
echo -e "${GREEN}Deployment process completed!${NC}"
echo -e "For more information and advanced configuration, see:"
echo -e "  - README.md in the ${DEPLOY_DIR} directory"
echo -e "  - DEPLOY.md in the root directory"
echo
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "1. Test local access at: https://${N8N_DOMAIN}"
echo -e "2. Verify port forwarding to enable external access"
echo -e "3. Test external access from a different network"
