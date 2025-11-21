#!/bin/bash
# Restore custom deployment fixes that may have been overwritten during merge
# Usage: ./scripts/restore-custom-fixes.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

echo "Restoring custom deployment fixes..."

# Restore vite.config.mts dedupe configuration
echo "Checking vite.config.mts..."
if ! grep -q "Fix Rolldown module resolution" packages/frontend/editor-ui/vite.config.mts; then
    echo "  Restoring Rolldown dedupe configuration..."
    # This is a complex edit, so we'll use a more targeted approach
    # The actual restoration should be done manually or with a more sophisticated script
    echo "  ⚠️  Manual intervention needed for vite.config.mts"
    echo "     Add the dedupe configuration to resolve.dedupe array"
fi

# Restore @lezer/common dependency
echo "Checking codemirror-lang-sql package.json..."
if ! grep -q "@lezer/common" packages/@n8n/codemirror-lang-sql/package.json; then
    echo "  Restoring @lezer/common dependency..."
    # Use a simple sed or node script to add the dependency
    # For now, we'll just report it
    echo "  ⚠️  Manual intervention needed for package.json"
    echo "     Add \"@lezer/common\": \"^1.0.0\" to dependencies"
fi

# Restore .gitignore entries
echo "Checking .gitignore..."
if ! grep -q "_backups/" .gitignore; then
    echo "  Restoring private files entries in .gitignore..."
    if ! grep -q "# Private files" .gitignore; then
        echo "" >> .gitignore
        echo "# Private files" >> .gitignore
    fi
    if ! grep -q "_backups/" .gitignore; then
        echo "_backups/" >> .gitignore
    fi
    if ! grep -q "_private_docs/" .gitignore; then
        echo "_private_docs/" >> .gitignore
    fi
    echo "  ✓ Restored .gitignore entries"
fi

echo ""
echo "Run ./scripts/verify-custom-fixes.sh to verify all fixes are present"

