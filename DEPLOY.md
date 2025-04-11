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
- Static IP for your home/office
- Open ports 80 and 443 on your firewall/router pointed to your PC/Mac static IP

## Network Configuration Requirements

For your n8n instance to be accessible from the internet, you need to:

1. **Configure Your Router/Firewall**:
   - Forward ports 80 (HTTP) and 443 (HTTPS) to your machine's internal IP address
   - Log into your router's admin panel (typically http://192.168.1.1 or http://192.168.0.1)
   - Find the port forwarding section (may be under "Advanced Settings", "NAT", or "Virtual Server")
   - Create two port forwarding rules:
     - Forward external port 80 to internal port 80 on your machine's IP
     - Forward external port 443 to internal port 443 on your machine's IP

2. **Set Up Static IP**:
   - Assign a static internal IP to your machine running n8n
   - This ensures port forwarding rules remain valid after reboots
   - Can be configured in your router settings or computer network settings

3. **Verify External Access**:
   - After deployment, test external access by:
     - Connecting from a mobile device (with WiFi off)
     - Using a service like https://www.whatismyip.com/ to find your public IP
     - Accessing https://your-domain.com from an external network

4. **Troubleshooting Connection Issues**:
   - If you can access locally but not externally, check:
     - Router port forwarding rules
     - Firewall settings on your machine
     - ISP blocking (some residential ISPs block ports 80/443)

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
