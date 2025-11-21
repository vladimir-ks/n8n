#!/bin/bash
# Safe merge script with integration branch workflow
# Usage: ./scripts/merge-upstream-safe.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 Safe Upstream Merge Workflow${NC}"
echo ""

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "integration" ]; then
    echo -e "${YELLOW}⚠️  Warning: Not on integration branch (currently on $CURRENT_BRANCH)${NC}"
    read -p "Switch to integration branch? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Check if integration branch exists
        if git show-ref --verify --quiet refs/heads/integration; then
            git checkout integration
        else
            echo -e "${YELLOW}Integration branch doesn't exist. Creating it...${NC}"
            git checkout -b integration
            git push -u origin integration
        fi
    else
        exit 1
    fi
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}✗ You have uncommitted changes. Please commit or stash them first.${NC}"
    exit 1
fi

# Verify custom fixes before merge
echo "Verifying custom fixes..."
if ! ./scripts/verify-custom-fixes.sh; then
    echo -e "${RED}✗ Custom fixes verification failed. Please fix issues before merging.${NC}"
    exit 1
fi

# Fetch upstream
echo ""
echo "Fetching upstream changes..."
git fetch upstream
git fetch origin

# Check if integration is behind master
if git show-ref --verify --quiet refs/remotes/origin/master; then
    BEHIND_MASTER=$(git rev-list --count integration..origin/master)
    if [ "$BEHIND_MASTER" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Integration is $BEHIND_MASTER commits behind master${NC}"
        read -p "Sync with master first? (recommended) (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git merge origin/master --no-edit
        fi
    fi
fi

# Show what will be merged
echo ""
echo "Upstream commits to merge:"
git log HEAD..upstream/master --oneline | head -10
COMMIT_COUNT=$(git rev-list --count HEAD..upstream/master)
if [ "$COMMIT_COUNT" -gt 10 ]; then
    echo "... and $(($COMMIT_COUNT - 10)) more commits"
fi

# Detect file deletions
echo ""
echo "Checking for file deletions in upstream..."
DELETED_FILES=$(git diff --name-status HEAD..upstream/master | grep "^D" | cut -f2 || true)
if [ -n "$DELETED_FILES" ]; then
    echo -e "${YELLOW}⚠️  Upstream deleted these files:${NC}"
    echo "$DELETED_FILES" | head -20
    DELETE_COUNT=$(echo "$DELETED_FILES" | wc -l)
    if [ "$DELETE_COUNT" -gt 20 ]; then
        echo "... and $(($DELETE_COUNT - 20)) more files"
    fi
    echo ""
    echo -e "${YELLOW}Make sure these deletions are expected!${NC}"
fi

# Confirm merge
echo ""
read -p "Proceed with merge to integration branch? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Merge cancelled."
    exit 0
fi

# Perform merge
echo ""
echo "Merging upstream/master into integration..."
if git merge upstream/master --no-edit; then
    echo -e "${GREEN}✓ Merge completed successfully${NC}"
else
    echo -e "${RED}✗ Merge had conflicts${NC}"
    echo "Steps to resolve:"
    echo "  1. Resolve conflicts manually"
    echo "  2. git add <resolved-files>"
    echo "  3. git commit"
    echo "  4. Run this script again to verify"
    exit 1
fi

# Verify custom fixes after merge
echo ""
echo "Verifying custom fixes after merge..."
if ! ./scripts/verify-custom-fixes.sh; then
    echo -e "${YELLOW}⚠️  Some custom fixes may have been overwritten${NC}"
    read -p "Restore custom fixes automatically? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./scripts/restore-custom-fixes.sh
        ./scripts/verify-custom-fixes.sh
    fi
fi

# Update lockfile if needed
if git diff --name-only | grep -q "pnpm-lock.yaml"; then
    echo ""
    echo "Staging updated pnpm-lock.yaml..."
    git add pnpm-lock.yaml
fi

echo ""
echo -e "${GREEN}✓ Merge to integration branch complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Test the build: pnpm install && pnpm build > build.log 2>&1"
echo "  2. Review build log: tail -50 build.log"
echo "  3. If build succeeds:"
echo "     - Push integration: git push origin integration"
echo "     - Test in non-production environment (if available)"
echo "     - Merge to master: git checkout master && git merge integration"
echo "     - Push to deploy: git push origin master"
echo ""
echo -e "${YELLOW}⚠️  Only merge to master after successful build verification!${NC}"
