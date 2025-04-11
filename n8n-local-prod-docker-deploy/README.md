# n8n Production Deployment

This repository contains the configuration files for deploying n8n in a production environment using Docker and Nginx.

## Table of Contents
- [Files and Structure](#files-and-structure)
- [Prerequisites](#prerequisites)
- [Post-Clone Setup](#post-clone-setup)
- [Templating System](#templating-system)
- [Quick Start](#quick-start)
- [SSL Certificate Management](#ssl-certificate-management)
- [Environment Variables](#environment-variables)
- [Dual Deployment Architecture](#dual-deployment-architecture)
- [Data Persistence](#data-persistence)
- [Custom Modules](#custom-modules)
- [Backup System](#backup-system)
- [Monitoring and Maintenance](#monitoring-and-maintenance)
- [Mac-Specific 24/7 Operation](#mac-specific-247-operation)
- [Security Considerations](#security-considerations)
- [Cloud Deployment (Render.com)](#cloud-deployment-rendercom)
- [Sharing Workflows & Credentials](#sharing-workflows--credentials-between-environments)
- [Troubleshooting](#troubleshooting)
- [Development Guidelines](#development-guidelines)
- [GitHub Repository Privacy](#github-repository-privacy)

## Files and Structure

- `docker-compose.yaml`: Docker Compose configuration for n8n and Nginx
- `nginx.conf`: Nginx configuration with SSL support
- `default.conf`: Empty configuration to override default Nginx settings
- `.env`: Environment variables for n8n (not tracked in git for security)
- `.env.example`: Example environment file with required variables
- `.env.template`: Template for the environment file with placeholders
- `.env.private.example`: Example private configuration with documentation
- `.env.private`: Your specific configuration values (not committed to git)
- `logs/`: Directory for Nginx logs
- `Dockerfile`: Custom n8n image with additional modules installed
- `setup.sh`: Main setup script for local environment
- `backup.sh` and `backup-to-gdrive.sh`: Backup utilities
- `setup-backup-schedule.sh`: Script to configure automated backups
- `setup-autostart.sh`: Script to configure auto-start on Mac
- `n8n-watchdog.sh`: Monitoring script for n8n containers
- `apply-templates.sh`: Script to apply template files with your configuration
- `copy-certs.sh`: Helper script to prepare SSL certificates with proper permissions
- `deployment-notes.md`: Documentation of deployment issues and solutions

## Prerequisites

- Docker and Docker Compose installed
- SSL certificates for the domain (Let's Encrypt)
- Domain DNS pointing to server (for production)
- Required ports (80 and 443) open on the server
- Node.js (version specified in .env file)
- Nginx for reverse proxy (included in Docker configuration)

## Post-Clone Setup

When you first clone this repository, you need to make the scripts executable:

```bash
# Make all shell scripts executable
chmod +x *.sh
```

This step is necessary because Git doesn't preserve executable permissions when cloning repositories.

## Templating System

This repository uses a template-based configuration system to protect sensitive information:

1. Configuration files are stored as templates (*.template) with placeholders
2. You provide your specific values in a private configuration file
3. The `apply-templates.sh` script generates actual configuration files

### How to Use Templates

1. Copy `.env.private.example` to `.env.private` and add your values:
   ```bash
   cp .env.private.example .env.private
   nano .env.private  # Edit with your specific values
   ```

2. Run the template application script:
   ```bash
   ./apply-templates.sh
   ```

3. Review generated files and start your n8n instance:
   ```bash
   ./setup.sh
   ```

### Template Variables

Important variables to configure:

- `N8N_DOMAIN`: Your n8n domain (e.g., n8n.example.com)
- `N8N_DATA_DIR`: Directory where n8n data is stored
- `SSL_CERTS_DIR`: Directory where SSL certificates are stored
- `SSL_CERT_PATH` and `SSL_KEY_PATH`: Paths to your SSL certificate files
- `N8N_ENCRYPTION_KEY`: Security key for encrypting sensitive data

See `.env.private.example` for all required variables and documentation.

## Quick Start

1. Clone this repository
2. Make scripts executable: `chmod +x *.sh`
3. Run `./apply-templates.sh` to set up your configuration
4. Run `./copy-certs.sh` to prepare SSL certificates
5. Run `./setup.sh` to deploy n8n

## SSL Certificate Management

SSL certificates from Let's Encrypt have strict permissions that can cause issues when mounted in Docker containers. We've implemented a solution:

1. The `copy-certs.sh` script creates a copy of your certificates with appropriate permissions
2. These copies are stored in `~/ssl-certs/DOMAIN_NAME/` directory
3. Docker mounts this directory instead of accessing the original certificates

Execute this step before running the setup script:

```bash
./copy-certs.sh
```

The script handles:
- Copying certificates from the Let's Encrypt directory
- Setting appropriate permissions
- Creating the necessary directory structure

## Environment Variables

Configuration is managed through environment variables defined in your `.env.private` file and applied to the templates:

```
# Domain configuration
N8N_PROTOCOL=https
N8N_PORT=5678
N8N_DOMAIN=n8n.example.com

# Security
N8N_ENCRYPTION_KEY=your_encryption_key  # MUST be identical in both environments
```

> **⚠️ IMPORTANT**: Using the same `N8N_ENCRYPTION_KEY` in both production and development environments is critical for sharing credentials and encrypted data.

## Critical Configuration Variables

For proper functioning of n8n v1.86+, these configuration variables are essential:

### Endpoint Configuration
```
# Force URL settings to be used - critical for proper operation
N8N_ENDPOINT_REST=rest
N8N_ENDPOINT_WEBHOOK=webhook
N8N_ENDPOINT_WEBSOCKET=websocket
```

These variables ensure:
- REST API endpoints work correctly (authentication, user creation)
- Webhook URLs don't display port numbers
- Real-time connection for workflow editing works properly

### Webhook URL Configuration
```
# Webhook URLs without port in the URL
N8N_WEBHOOK_URL=https://yourdomain.com/webhook/
N8N_WEBHOOK_TEST_URL=https://yourdomain.com/webhook-test/
```

### Production Mode Settings
```
# Force production mode
NODE_ENV=production
N8N_DISABLE_PRODUCTION_MAIN_PROCESS=false
```

> **⚠️ IMPORTANT**: The `N8N_ENDPOINT_REST` value should be set to `rest` (not a full URL) to prevent API errors.

## Dual Deployment Architecture

This repository supports two deployments:

### 1. Local Development Deployment
- Uses Docker with a custom image that includes additional modules
- Resources: Uses your local machine's CPU and memory
- Best for: Resource-intensive workflows and development
- Accessible at your configured local domain

### 2. Cloud Deployment (e.g., Render.com)
- Connected to the GitHub repository
- Built automatically when changes are pushed
- Resources: Uses cloud infrastructure
- Best for: Mission-critical workflows that need 24/7 availability
- Accessible at your configured cloud domain

## Data Persistence

The n8n data is stored in the directory specified by `N8N_DATA_DIR` (default: `~/.n8n/`) and mounted as a Docker volume, ensuring data persistence across restarts.

## Custom Modules

Both environments are configured to use these custom modules:
- External: jszip, lodash, ajv, moment, axios, crypto-js, validator, node-fetch, fast-xml-parser, cheerio
- Built-in: fs, crypto, path, http, https, os, stream, events, util, zlib, net, dns, timers

The Dockerfile ensures these modules are installed in the local environment. By default, playwright is excluded due to its large size, but you can uncomment the relevant line in the Dockerfile if you need it.

## Backup System

Three backup mechanisms are provided:

1. **Local backups**: `./backup.sh` creates backups in `~/n8n-backups/`
2. **Google Drive backups**: `./backup-to-gdrive.sh` syncs backups to Google Drive
3. **Scheduled backups**: `./setup-backup-schedule.sh` sets up daily backups at 2 AM

To set up the backup schedule:
```bash
./setup-backup-schedule.sh
```

## Monitoring and Maintenance

- Check logs: `docker compose logs -f`
- Check logs in the `logs/` directory for Nginx issues
- Restart services: `docker compose restart`
- Update n8n: Update the image version in Dockerfile and run `docker compose up -d`

The `n8n-watchdog.sh` script monitors system health and can be configured as a cron job with `./setup-autostart.sh`.

## Mac-Specific 24/7 Operation

To ensure n8n runs reliably 24/7 on macOS:

1. Use Amphetamine app to prevent Mac from sleeping
2. Set Docker to start on login
3. Use the provided scripts:
   - `./setup-autostart.sh`: Sets up auto-start on login
   - `./n8n-watchdog.sh`: Monitors and restarts containers if needed

## Security Considerations

- The encryption key in `.env` is used to secure sensitive data
- Keep your `.env` file secure and excluded from version control
- Regularly update Docker images and dependencies
- Use proper firewall rules to limit access
- SSL certificates are copied with appropriate permissions to avoid exposure

## Cloud Deployment (Render.com)

For Render.com deployment:
1. Connect your GitHub repository
2. Use the Dockerfile in this directory
3. Set all environment variables from `.env.example`
4. Configure persistent volume for data storage

## Sharing Workflows & Credentials Between Environments

To transfer workflows and credentials between environments:
1. Ensure both environments use the same `N8N_ENCRYPTION_KEY`
2. Export workflow from source environment (with credentials)
3. Import to destination environment

## Troubleshooting

Common issues and solutions:

### Permission Issues
- **SSL Certificates**: If nginx cannot read SSL certificates, run `./copy-certs.sh` to create properly permissioned copies
- **NPM Package Installation**: We've modified the Dockerfile to install packages as the node user to avoid permission issues
- **Data Directory**: Ensure the n8n data directory has appropriate permissions with `chmod -R 755 ~/.n8n_*`

### Container Issues
- **Template Substitution Problems**: If generated files have empty values, check that your `.env.private` file contains all required variables
- **Nginx Restart Loop**: Check nginx logs with `docker logs n8n-local-prod-docker-deploy-nginx-1` to identify configuration issues
- **N8N Container Crashes**: Check logs with `docker logs n8n-local-prod-docker-deploy-n8n-1` and adjust memory limits if needed

### Connectivity Issues
- **Cannot Access Web UI**: Verify domain is in `/etc/hosts` and pointed to 127.0.0.1 for local development
- **SSL Certificate Errors**: Ensure the certificates are properly copied and nginx configuration points to correct paths
- **WebSocket Connection Failures**: Check nginx configuration for proper WebSocket handling directives

## Development Guidelines

When modifying this project, ensure:

### Environment Compatibility

This project must always maintain compatibility with both deployment targets:

1. **Local Development Deployment**:
   - Must work on macOS with Docker and Docker Compose
   - Uses local domain mapping (domain.com → 127.0.0.1)
   - Requires SSL certificates to be available locally

2. **Cloud Deployment**:
   - Must work on Render's infrastructure without modification
   - Same files and configuration should work in both environments

### Code Modification Rules

1. **Environment Variables**:
   - All configurable options should use environment variables
   - Do not hardcode values that differ between environments

2. **Path References**:
   - Use relative paths when possible
   - When absolute paths are necessary, ensure they exist in both environments or use environment variables

3. **Domain Configuration**:
   - Keep domain references in configurable locations
   - Ensure the setup script can adapt to different domains

4. **Docker Configuration**:
   - Maintain compatibility with Docker Desktop (Mac) and Render's Docker implementation
   - Use modern `docker compose` syntax instead of `docker-compose`

### Testing Requirements

Before committing changes:
1. Test the setup on a local Mac environment
2. Ensure all scripts run without errors
3. Verify that no changes would break the Render deployment
4. Check that environment switching works seamlessly

## GitHub Repository Privacy

If you make the GitHub repository private:
1. Render.com will need to be reconnected with proper authorization
2. Update Render.com settings in the "Build & Deploy" section
3. Local git operations will continue to work but may require SSH keys or tokens
