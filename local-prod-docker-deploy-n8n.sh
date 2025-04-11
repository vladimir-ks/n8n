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
