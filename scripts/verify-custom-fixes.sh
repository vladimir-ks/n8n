#!/bin/bash
# Verify that custom deployment fixes are still present after a merge
# Usage: ./scripts/verify-custom-fixes.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Checking custom deployment fixes..."

ERRORS=0

# Check 1: vite.config.mts should have dedupe configuration
echo -n "Checking vite.config.mts for Rolldown dedupe fix... "
if grep -q "Fix Rolldown module resolution" packages/frontend/editor-ui/vite.config.mts && \
   grep -q "@codemirror/autocomplete" packages/frontend/editor-ui/vite.config.mts; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ MISSING${NC}"
    echo "  Expected: Rolldown dedupe configuration for @codemirror packages"
    ERRORS=$((ERRORS + 1))
fi

# Check 2: codemirror-lang-sql should have @lezer/common dependency
echo -n "Checking codemirror-lang-sql for @lezer/common dependency... "
if grep -q "@lezer/common" packages/@n8n/codemirror-lang-sql/package.json; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ MISSING${NC}"
    echo "  Expected: @lezer/common dependency in package.json"
    ERRORS=$((ERRORS + 1))
fi

# Check 3: .gitignore should have private files entries
echo -n "Checking .gitignore for private files entries... "
if grep -q "_backups/" .gitignore && grep -q "_private_docs/" .gitignore; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ MISSING${NC}"
    echo "  Expected: _backups/ and _private_docs/ entries"
    ERRORS=$((ERRORS + 1))
fi

# Check 4: Detect files that should have been deleted
echo ""
echo "Checking for orphaned files that should have been deleted..."
ORPHANED=0

# Check for invalid-mode.error.ts (should have been deleted in upstream)
if [ -f "packages/core/src/errors/invalid-mode.error.ts" ]; then
    echo -e "${YELLOW}⚠️  Found orphaned file: packages/core/src/errors/invalid-mode.error.ts${NC}"
    echo "  This file was deleted upstream and should be removed"
    ORPHANED=$((ORPHANED + 1))
fi

# Add more orphaned file checks as needed

if [ $ORPHANED -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Found $ORPHANED orphaned file(s)${NC}"
    echo "These files may cause build errors and should be removed."
fi

echo ""
if [ $ERRORS -eq 0 ] && [ $ORPHANED -eq 0 ]; then
    echo -e "${GREEN}✓ All custom deployment fixes are present and no orphaned files found!${NC}"
    exit 0
elif [ $ERRORS -gt 0 ]; then
    echo -e "${RED}✗ Found $ERRORS missing custom fix(es)${NC}"
    echo "To restore fixes, run: ./scripts/restore-custom-fixes.sh"
    exit 1
else
    echo -e "${YELLOW}⚠️  Found orphaned files but custom fixes are intact${NC}"
    echo "Consider cleaning up orphaned files before proceeding."
    exit 0
fi

