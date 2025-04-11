# n8n Production Deployment

This repository contains the configuration files for deploying n8n in a production environment using Docker and Nginx.

## Files

- `docker-compose.yaml`: Docker Compose configuration for n8n and Nginx
- `nginx.conf`: Nginx configuration with SSL support
- `default.conf`: Empty configuration to override default Nginx settings
- `.env`: Environment variables for n8n (not tracked in git for security)
- `logs/`: Directory for Nginx logs
- `Dockerfile`: Custom n8n image with additional modules installed

## Prerequisites

- Docker and Docker Compose installed
- SSL certificates for the domain (Let's Encrypt)
- Domain DNS pointing to server (for production)
- Required ports (80 and 443) open on the server

## Setup

1. Clone this repository
2. Ensure SSL certificates are in `/etc/letsencrypt/live/ai.vladks.com/`
3. Create an `.env` file with necessary environment variables (see below)
4. Start the services with `docker-compose up -d`

### Important Environment Variables

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

## Persistence

The n8n data is stored in `~/.n8n` directory on the host machine, ensuring data persistence across restarts.

## Access

- Local n8n web interface: https://ai.vladks.com
- Render n8n web interface: https://n8n.vladks.com
- n8n API: https://[your-domain]/webhook/

## Dual Deployment Architecture

This repository supports two deployments:

### 1. Local Mac Deployment (ai.vladks.com)
- Uses Docker with a custom image that includes additional modules
- Resources: Uses your Mac's CPU and memory
- Best for: Resource-intensive workflows and development

### 2. Render.com Deployment (n8n.vladks.com)
- Connected to the GitHub repository
- Built automatically when changes are pushed
- Resources: Uses Render's cloud infrastructure
- Best for: Mission-critical workflows that need 24/7 availability

### Sharing Workflows & Credentials Between Environments

To transfer workflows and credentials between environments:
1. Ensure both environments use the same `N8N_ENCRYPTION_KEY`
2. Export workflow from source environment (with credentials)
3. Import to destination environment

## Custom Modules

Both environments are configured to use these custom modules:
- External: jszip, lodash, ajv, moment, axios, crypto-js, validator, node-fetch, fast-xml-parser, playwright, cheerio
- Built-in: fs, crypto, path, http, https, os, stream, events, util, zlib, net, dns, timers

The Dockerfile ensures these modules are installed in the local environment.

## Monitoring and Maintenance

- Check logs: `docker-compose logs`
- Restart services: `docker-compose restart`
- Update n8n: Update the image version in Dockerfile and run `docker-compose up -d`

## Mac-Specific 24/7 Operation

To ensure n8n runs reliably 24/7 on macOS:

1. Use Amphetamine app to prevent Mac from sleeping
2. Set Docker to start on login
3. Use the provided scripts:
   - `./setup-autostart.sh`: Sets up auto-start on login
   - `./n8n-watchdog.sh`: Monitors and restarts containers if needed

## Backup

The following backup systems are in place:
1. Local backups: `./backup.sh` creates backups in `~/n8n-backups/`
2. Google Drive backups: `./backup-to-gdrive.sh` syncs backups to Google Drive
3. Scheduled backups: `./setup-backup-schedule.sh` sets up daily backups at 2 AM

## GitHub Repository Privacy

If you make the GitHub repository private:
1. Render.com will need to be reconnected with proper authorization
2. Update Render.com settings in the "Build & Deploy" section
3. Local git operations will continue to work but may require SSH keys or tokens
