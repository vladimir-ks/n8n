# n8n Environment Variables Guide

This document explains how environment variables are used across the n8n deployment, their relationships, and potential issues to watch for.

## Environment Variable Sources

In this deployment, environment variables are defined in multiple places:

1. **`.env.private`**: Source of truth for deployment-specific values
   - Contains your specific configuration
   - Used to populate templates
   - Not committed to git

2. **`.env` (generated from template)**:
   - Used by n8n directly when running
   - Mounted into the container at `/home/node/.n8n/.env`

3. **`docker-compose.yaml` environment section**:
   - Defines environment for the n8n container
   - **Takes precedence over values in the mounted `.env` file**

## Variable Precedence

When variables are defined in multiple places, they follow this order of precedence:

1. Variables defined in `docker-compose.yaml`'s environment section (highest priority)
2. Variables from mounted `.env` file
3. Default values built into n8n

## Critical Variables

These variables are essential for proper operation and should be exactly as specified:

### Endpoint Configuration
```
N8N_ENDPOINT_REST=rest
N8N_ENDPOINT_WEBHOOK=webhook
N8N_ENDPOINT_WEBSOCKET=websocket
```

These must be configured exactly as shown. In particular:
- `N8N_ENDPOINT_REST` must be `rest`, not a URL
- Setting these correctly fixes many common issues with n8n v1.86+

### Security
```
N8N_ENCRYPTION_KEY=your_encryption_key
```

This must be identical across environments if you want to share credentials.

## Duplicated Variables

Some variables appear in both `.env` and `docker-compose.yaml`:

| Variable | In .env | In docker-compose.yaml | Recommendation |
|----------|---------|------------------------|----------------|
| N8N_HOST | ✓ | ✓ | Keep in both |
| N8N_PROTOCOL | ✓ | ✓ | Keep in both |
| N8N_ENDPOINT_REST | ✓ | ✓ | Keep in both (critical) |
| N8N_WEBHOOK_URL | ✓ | ✓ | Keep in both |
| NODE_ENV | ✓ | ✓ | Keep in both |

This duplication is intentional to ensure the variables are set even if the `.env` file is missing or ignored.

## Render.com Deployment Variables

For Render.com deployments, you need these essential variables:

### Minimum Required Set

```
N8N_ENCRYPTION_KEY=your_encryption_key
N8N_ENDPOINT_REST=rest
N8N_ENDPOINT_WEBHOOK=webhook
N8N_ENDPOINT_WEBSOCKET=websocket
N8N_EDITOR_BASE_URL=https://your-domain.com
```

### Optional But Recommended
```
N8N_HOST=your-domain.com
N8N_PROTOCOL=https
N8N_WEBHOOK_URL=https://your-domain.com/webhook/
N8N_WEBHOOK_TEST_URL=https://your-domain.com/webhook-test/
NODE_ENV=production
N8N_DISABLE_PRODUCTION_MAIN_PROCESS=false
```

## Template System Issues to Watch For

When using the template system, be aware of these potential issues:

1. **Missing Variables**:
   - The template requires all variables from `.env.private`
   - Missing variables will result in empty values in generated files

2. **Inconsistent Values**:
   - Ensure that variable values are consistent where duplicated
   - Conflicting values can cause unpredictable behavior

3. **Template Processing Order**:
   - Templates are processed in the order they're found
   - Dependencies between template files are not managed automatically

## Best Practices

1. **Use the Templating System**: Always use the template system to manage your configuration.

2. **Validate Generated Files**: After running `apply-templates.sh`, review the generated files.

3. **Keep Critical Variables Duplicated**: Variables critical for operation should exist in both `.env` and `docker-compose.yaml`.

4. **Minimize Deployment-Specific Values**: Only values that truly vary between deployments should be in `.env.private`.

5. **Version Your Templates**: When you make changes to the configuration, update the templates first.

## Troubleshooting Template Issues

If you encounter issues with variable substitution:

1. **Check for Missing Variables**:
   ```bash
   grep -o '\${[A-Za-z0-9_]*}' filename
   ```

2. **Verify Source Values**:
   ```bash
   grep "VARIABLE_NAME" .env.private
   ```

3. **Check Effective Values in Container**:
   ```bash
   docker compose exec n8n env | grep VARIABLE_NAME
   ```
