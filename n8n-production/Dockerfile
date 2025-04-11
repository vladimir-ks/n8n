FROM n8nio/n8n:latest

# Install custom modules
RUN cd /usr/local/lib/node_modules/n8n && \
    npm install jszip lodash ajv moment axios crypto-js validator node-fetch fast-xml-parser playwright cheerio

# Set working directory
WORKDIR /home/node/.n8n

# The environment variables will be provided by docker-compose
# from the mounted .env file

# Default command
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
