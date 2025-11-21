#!/bin/bash
# Restore custom deployment fixes that may have been overwritten during merge
# Usage: ./scripts/restore-custom-fixes.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

echo "Restoring custom deployment fixes using patches..."

# Use git apply to restore our custom fixes.
# This is better than checkout because it preserves upstream changes and only applies our specific fix.
# It will fail if the context for the patch has changed too much, which is a good signal for manual review.

echo "  -> Applying Rolldown dedupe configuration..."
git apply --reject --whitespace=fix "scripts/patches/vite-dedupe.patch"

echo "  -> Applying @lezer/common dependency..."
git apply --reject --whitespace=fix "scripts/patches/codemirror-lezer-dep.patch"

echo "  -> Applying .gitignore private file entries..."
git apply --reject --whitespace=fix "scripts/patches/gitignore-private-files.patch"

# Update lockfile if package.json files were modified
echo ""
echo "Updating pnpm-lock.yaml to sync with package.json changes..."
if pnpm install --lockfile-only; then
    echo "  ✓ Lockfile updated successfully"
else
    echo "  ⚠️  Warning: Failed to update lockfile. You may need to run 'pnpm install' manually."
fi

echo ""
echo "Restore process finished. Please check for any '.rej' files, which indicate failed patches."
echo "Run './scripts/verify-custom-fixes.sh' to confirm all fixes are present."

