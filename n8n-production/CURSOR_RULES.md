# Cursor Rules for n8n Deployment Project

## Dual Deployment Compatibility

This project must always maintain compatibility with two deployment targets:

1. **Local Mac Deployment**:
   - Must work on macOS with Docker and Docker Compose
   - Uses local domain mapping (ai.vladks.com → 127.0.0.1)
   - Requires SSL certificates to be available locally

2. **Render Cloud Deployment**:
   - Must work on Render's infrastructure without modification
   - Same files and configuration should work in both environments
   - No hardcoded paths or configurations that would break cloud deployment

## Code Modification Rules

When modifying this project, ensure:

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
   - Maintain compatibility with both Docker Desktop (Mac) and Render's Docker implementation
   - Use standard Docker features supported in both environments

## Testing Requirements

Before committing changes:

1. Test the setup on a local Mac environment
2. Ensure all scripts run without errors
3. Verify that no changes would break the Render deployment
4. Check that environment switching works seamlessly

## Repository Organization

Maintain a clear separation between:

1. Core service files (docker-compose.yaml, nginx.conf)
2. Local-only utilities (setup scripts, local management tools)
3. Documentation (README.md, usage instructions)

This ensures that code changes can be tracked and deployed to both environments with confidence.
