# n8n Deployment Setup Guide

This guide covers setting up n8n in both local and cloud environments.

## Deployment Environments

This repository contains configuration for two environments:
- **Local Development**: Hosted at ai.vladks.com
- **Cloud Production**: Hosted at n8n.vladks.com on Render.com

## Setup Requirements

- Docker and Docker Compose
- Node.js (version specified in .env file)
- Nginx for reverse proxy (included in Docker configuration)
- SSL certificates (Let's Encrypt recommended)
- Required ports (80 and 443) open on the server

## Quick Start

1. Clone this repository
2. Copy `.env.example` to `.env` and update the values
3. Run `./setup.sh` to prepare the environment
4. Start n8n with `docker-compose up -d`

## Environment Variables

Key environment variables are configured in the `.env` file:
- Connection settings (host, port, protocol)
- Node.js configuration
- External modules allowlist
- Encryption key (MUST be set securely)

See `.env.example` for a full list of required variables.

## Data Persistence

n8n data is stored in `~/.n8n/` and mounted as a Docker volume.

## Backup System

Two backup mechanisms are provided:
1. Local backups to `~/n8n-backups`
2. Google Drive backups via rclone

Setup the backup schedule with `./setup-backup-schedule.sh`

## Monitoring

- The `n8n-watchdog.sh` script monitors system health
- Configure cron jobs with `./setup-autostart.sh`

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

## Troubleshooting

Check logs in the `logs/` directory for issues.

Common issues:
- Permission problems: Ensure volume mounts have correct permissions
- Memory limitations: Adjust `NODE_OPTIONS` in `.env`
- Module access: Verify external modules are in the allowlist
