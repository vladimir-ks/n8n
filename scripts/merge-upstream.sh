#!/bin/bash
# Safe merge script that preserves custom deployment fixes
# Usage: ./scripts/merge-upstream.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔄 Merging upstream changes..."

# Check if we're on master branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "master" ]; then
    echo -e "${YELLOW}⚠️  Warning: Not on master branch (currently on $CURRENT_BRANCH)${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}✗ You have uncommitted changes. Please commit or stash them first.${NC}"
    exit 1
fi

# Verify custom fixes are present before merge
echo ""
echo "Verifying custom fixes before merge..."
if ! ./scripts/verify-custom-fixes.sh; then
    echo -e "${RED}✗ Custom fixes verification failed. Please fix issues before merging.${NC}"
    exit 1
fi

# Fetch upstream
echo ""
echo "Fetching upstream changes..."
git fetch upstream

# Show what will be merged
echo ""
echo "Upstream commits to merge:"
git log HEAD..upstream/master --oneline | head -10
if [ $(git rev-list --count HEAD..upstream/master) -gt 10 ]; then
    echo "... and $(($(git rev-list --count HEAD..upstream/master) - 10)) more commits"
fi

# Confirm merge
echo ""
read -p "Proceed with merge? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Merge cancelled."
    exit 0
fi

# Perform merge
echo ""
echo "Merging upstream/master..."
if git merge upstream/master --no-edit; then
    echo -e "${GREEN}✓ Merge completed successfully${NC}"
else
    echo -e "${RED}✗ Merge had conflicts${NC}"
    echo "Resolve conflicts and then run: ./scripts/verify-custom-fixes.sh"
    exit 1
fi

# Verify custom fixes after merge
echo ""
echo "Verifying custom fixes after merge..."
if ./scripts/verify-custom-fixes.sh; then
    echo ""
    echo -e "${GREEN}✓ All custom fixes preserved!${NC}"

    # Check if lockfile was modified and stage it
    if git diff --name-only | grep -q "pnpm-lock.yaml"; then
        echo ""
        echo "Staging updated pnpm-lock.yaml..."
        git add pnpm-lock.yaml
        echo -e "${GREEN}✓ Lockfile staged${NC}"
    fi

    echo ""
    echo "Next steps:"
    echo "  1. Review the changes: git log HEAD~1..HEAD"
    echo "  2. Check lockfile changes: git diff --cached pnpm-lock.yaml | head -50"
    echo "  3. Test the build if needed"
    echo "  4. Commit if ready: git commit -m 'Merge upstream changes'"
    echo "  5. Push to origin: git push origin master"
else
    echo ""
    echo -e "${YELLOW}⚠️  Some custom fixes may have been overwritten${NC}"
    echo "Run ./scripts/restore-custom-fixes.sh to restore them"
    exit 1
fi

