# n8n Docker Deployment

This deployment solution allows you to run n8n on your local machine with Docker, making it accessible both locally and from the internet.

## Quick Start

1. **Create your configuration file**:
   ```bash
   cp .env.private.example .env.private
   # Edit .env.private with your domain and SSL certificate paths
   ```

2. **Run the deployment script**:
   ```bash
   chmod +x deploy-n8n.sh
   ./deploy-n8n.sh
   ```

3. **Access your n8n instance**:
   Open your browser and go to `https://your-domain.com`

## What This Solution Provides

- **Docker-based**: Run n8n in isolated containers with proper resource allocation
- **HTTPS Support**: Automatic SSL certificate configuration with Let's Encrypt
- **External Access**: Access your n8n instance from anywhere via your domain
- **Custom Modules**: Pre-installed modules including community nodes
- **Automatic Backups**: Scheduled backups to local storage or Google Drive
- **Monitoring**: System health checks and automatic restarts

## Requirements

- Docker and Docker Compose installed
- A domain name pointing to your server's IP
- SSL certificates (Let's Encrypt recommended) - we help with that.
- static ip for your home/office
- Open ports 80 and 443 on your firewall/router pointed to your pc/mac static ip

## Advanced Configuration

For detailed information about configuration options, backup setup, and monitoring:

1. See the full documentation in `n8n-docker-deploy/README.md`
2. Check the environment variables documentation in `n8n-docker-deploy/ENVIRONMENT_VARIABLES.md`

## Troubleshooting

Common issues and their solutions are documented in the deployment directory's README.

## Architecture

This deployment uses:
- **Nginx**: As a reverse proxy handling HTTPS
- **n8n**: Running in a Docker container with custom modules
- **Docker Compose**: Orchestrating the containers

## Maintenance

- **Starting/Stopping**: `cd n8n-docker-deploy && docker compose up -d` / `docker compose down`
- **Viewing Logs**: `cd n8n-docker-deploy && docker compose logs -f`
- **Updating**: Update the image version in Dockerfile and run `docker compose up -d`
