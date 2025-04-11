# n8n Production Deployment

This repository contains the configuration files for deploying n8n in a production environment using Docker and Nginx.

## Table of Contents
- [Files and Structure](#files-and-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
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
- `logs/`: Directory for Nginx logs
- `Dockerfile`: Custom n8n image with additional modules installed
- `setup.sh`: Main setup script for local environment
- `backup.sh` and `backup-to-gdrive.sh`: Backup utilities
- `setup-backup-schedule.sh`: Script to configure automated backups
- `setup-autostart.sh`: Script to configure auto-start on Mac
- `n8n-watchdog.sh`: Monitoring script for n8n containers

## Prerequisites

- Docker and Docker Compose installed
- SSL certificates for the domain (Let's Encrypt)
- Domain DNS pointing to server (for production)
- Required ports (80 and 443) open on the server
- Node.js (version specified in .env file)
- Nginx for reverse proxy (included in Docker configuration)

## Quick Start

1. Clone this repository
2. Copy `.env.example` to `.env` and update the values
3. Ensure SSL certificates are in `/etc/letsencrypt/live/ai.vladks.com/` (local)
4. Run `./setup.sh` to prepare the environment
5. Start the services with `docker-compose up -d`

## Environment Variables

The following environment variables should be set in your `.env` file locally and in Render.com:

```
# General configuration
N8N_EDITOR_BASE_URL=https://ai.vladks.com  # (or n8n.vladks.com for Render)
N8N_HOST=ai.vladks.com  # (or n8n.vladks.com for Render)
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_ENCRYPTION_KEY=your_encryption_key  # MUST be identical in both environments

# External modules allowed
NODE_FUNCTION_ALLOW_EXTERNAL=jszip,lodash,ajv,moment,axios,crypto-js,validator,node-fetch,fast-xml-parser,playwright,cheerio
NODE_FUNCTION_ALLOW_BUILTIN=fs,crypto,path,http,https,os,stream,events,util,zlib,net,dns,timers
```

> **⚠️ IMPORTANT**: Using the same `N8N_ENCRYPTION_KEY` in both Render.com and local deployments is critical for sharing credentials and encrypted data between environments.

See `.env.example` for a full list of required variables.

## Dual Deployment Architecture

This repository supports two deployments:

### 1. Local Mac Deployment (ai.vladks.com)
- Uses Docker with a custom image that includes additional modules
- Resources: Uses your Mac's CPU and memory
- Best for: Resource-intensive workflows and development
- Local n8n web interface: https://ai.vladks.com

### 2. Render.com Deployment (n8n.vladks.com)
- Connected to the GitHub repository
- Built automatically when changes are pushed
- Resources: Uses Render's cloud infrastructure
- Best for: Mission-critical workflows that need 24/7 availability
- Render n8n web interface: https://n8n.vladks.com

## Data Persistence

The n8n data is stored in `~/.n8n/` directory on the host machine and mounted as a Docker volume, ensuring data persistence across restarts.

## Custom Modules

Both environments are configured to use these custom modules:
- External: jszip, lodash, ajv, moment, axios, crypto-js, validator, node-fetch, fast-xml-parser, playwright, cheerio
- Built-in: fs, crypto, path, http, https, os, stream, events, util, zlib, net, dns, timers

The Dockerfile ensures these modules are installed in the local environment.

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

- Check logs: `docker-compose logs`
- Check logs in the `logs/` directory for Nginx issues
- Restart services: `docker-compose restart`
- Update n8n: Update the image version in Dockerfile and run `docker-compose up -d`

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

Common issues:

- **Permission problems**: Ensure volume mounts have correct permissions
- **Memory limitations**: Adjust `NODE_OPTIONS` in `.env`
- **Module access**: Verify external modules are in the allowlist
- **SSL issues**: Check certificate paths and validity
- **Docker networking**: Verify ports are properly mapped and accessible

## Development Guidelines

When modifying this project, ensure:

### Environment Compatibility

This project must always maintain compatibility with both deployment targets:

1. **Local Mac Deployment**:
   - Must work on macOS with Docker and Docker Compose
   - Uses local domain mapping (ai.vladks.com → 127.0.0.1)
   - Requires SSL certificates to be available locally

2. **Render Cloud Deployment**:
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
