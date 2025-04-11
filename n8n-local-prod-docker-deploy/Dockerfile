FROM n8nio/n8n:latest

# Install custom modules as the node user to avoid permission issues
USER node
RUN mkdir -p /home/node/.npm-global && \
    npm config set prefix '/home/node/.npm-global' && \
    npm install -g jszip lodash ajv moment axios crypto-js validator node-fetch fast-xml-parser cheerio n8n-nodes-mcp

# Exclude playwright because it's a large package that might not be necessary for all workflows
# If you need playwright, uncomment the following line and rebuild
# RUN npm install -g playwright

# Set working directory
WORKDIR /home/node/.n8n

# The environment variables will be provided by docker-compose
# from the mounted .env file

# Default command
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]