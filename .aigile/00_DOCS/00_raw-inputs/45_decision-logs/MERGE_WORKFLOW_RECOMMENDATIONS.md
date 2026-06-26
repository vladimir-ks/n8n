---
metadata:
  status: IN-REVIEW
  version: 1.0
  tldr: "Comprehensive recommendations for improving upstream merge workflow and deployment process"
---

# Merge Workflow Recommendations

## Executive Summary

Current merge process has gaps that led to recent deployment failures:
- **File deletions** from upstream aren't caught by verification
- **No build testing** before deploying to production
- **Direct merge to master** triggers immediate Render deployment
- **No rollback strategy** for failed merges

## Recommended Branching Strategy

### New Workflow: Integration Branch

```
upstream/master → integration → master (production)
                     ↓
                  Test & Build
```

**Benefits:**
- Test merges without triggering production deploys
- Opportunity to catch build errors before they reach production
- Easy rollback (just don't merge to master)
- Clean separation between merge activity and deployments

### Branch Structure

1. **`master`** - Production branch (Render watches this)
   - Only merge from `integration` after successful build
   - Protected branch with required status checks

2. **`integration`** - Merge staging branch
   - Merge upstream here first
   - Run full build and verification
   - Test deployment-specific fixes

3. **Feature branches** (optional) - For custom features
   - Branch from `master`
   - Merge back to `master` after review

## Implementation Steps

### 1. Create Integration Branch

```bash
# One-time setup
git checkout -b integration
git push -u origin integration

# Set integration as default branch for merges (optional)
# This can be done in GitHub settings
```

### 2. Update Render Configuration

**In Render Dashboard:**
- Ensure the service is watching the **`master`** branch (production)
- Consider adding manual deploy controls for safety

**About your GitHub username change:**
- Your remote is already updated: `vladimir-ks/n8n` ✓
- If Render shows errors about repo access:
  1. Go to Render Dashboard → Service → Settings
  2. Reconnect GitHub integration
  3. Select `vladimir-ks/n8n` repository
  4. Ensure branch is still set to `master`

### 3. Enhanced Merge Script

Create `scripts/merge-upstream-safe.sh`:

```bash
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
        git checkout integration
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
BEHIND_MASTER=$(git rev-list --count integration..origin/master)
if [ "$BEHIND_MASTER" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Integration is $BEHIND_MASTER commits behind master${NC}"
    read -p "Sync with master first? (recommended) (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git merge origin/master --no-edit
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
    if [ $(echo "$DELETED_FILES" | wc -l) -gt 20 ]; then
        echo "... and more"
    fi
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
```

### 4. Enhanced Verification Script

Update `scripts/verify-custom-fixes.sh` to detect orphaned files:

```bash
#!/bin/bash
# Enhanced verification with orphaned file detection
# Usage: ./scripts/verify-custom-fixes.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

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
```

## Workflow Comparison

### Old Workflow (Current)
```
1. Run ./scripts/merge-upstream.sh on master
2. Merge completes → automatic push → Render deploys
3. Build fails → production is down
4. Scramble to fix
```

**Risk:** High - production breaks immediately

### New Workflow (Recommended)
```
1. Run ./scripts/merge-upstream-safe.sh on integration
2. Test build locally
3. Fix any issues on integration branch
4. Only merge to master when confirmed working
5. Render deploys only after verification
```

**Risk:** Low - issues caught before production

## GitHub Configuration Updates

### Your Username Change

**Status:** ✓ Already handled correctly
- Remote URL: `vladimir-ks/n8n` ✓
- Git config: `vladimir-ks@users.noreply.github.com` ✓

**If Render can't find repo:**
1. Open Render Dashboard → Your Service
2. Settings → Repository
3. Click "Connect Repository" or "Reconnect"
4. Select `vladimir-ks/n8n`
5. Confirm branch is `master`

### Branch Protection (Recommended)

**In GitHub:**
1. Go to `vladimir-ks/n8n` → Settings → Branches
2. Add branch protection rule for `master`:
   - ☑ Require pull request reviews (optional)
   - ☑ Require status checks to pass (if you set up CI)
   - ☐ Allow force pushes (keep disabled)
   - ☐ Allow deletions (keep disabled)

3. Add branch protection for `integration`:
   - Less strict, mainly for visibility

## Testing Strategy

### Local Build Verification

After merging to integration, always test:

```bash
# Full clean build
pnpm install
pnpm run build > build.log 2>&1

# Check for errors
tail -100 build.log

# If successful, test specific packages
cd packages/core && pnpm build
cd packages/cli && pnpm build
cd packages/editor-ui && pnpm build
```

### Pre-Production Testing (Future Enhancement)

Consider setting up a Render preview environment:
- Create a separate Render service watching `integration` branch
- Free tier or cheaper plan for testing
- Test deployments before promoting to production

## Rollback Strategy

### If Deployment Fails

**Option 1: Revert on master**
```bash
git checkout master
git revert HEAD  # Reverts the merge commit
git push origin master
```

**Option 2: Force push previous commit (use carefully)**
```bash
git checkout master
git reset --hard HEAD~1
git push origin master --force
```

**Option 3: Deploy from previous tag**
```bash
# Tag working versions
git tag v-working-$(date +%Y%m%d-%H%M)
git push origin --tags

# To rollback
git checkout v-working-20251121-1000
git push origin HEAD:master --force
```

## Action Items

### Immediate (Today)
- [ ] Create `integration` branch
- [ ] Update Render to watch `master` (verify)
- [ ] Reconnect GitHub if needed (username change)

### Short-term (This Week)
- [ ] Create `scripts/merge-upstream-safe.sh`
- [ ] Update `scripts/verify-custom-fixes.sh` with orphaned file detection
- [ ] Document workflow in `.cursor/rules`
- [ ] Test workflow with next upstream merge

### Long-term (This Month)
- [ ] Set up branch protection on GitHub
- [ ] Consider Render preview environment
- [ ] Implement automated testing (optional)
- [ ] Create deployment tags for easy rollback

## Environment Variables

**Current Status:** ✓ No changes needed

Your Render configuration is correct:
- `NODE_VERSION=22.16` ✓
- Build command: `pnpm install --frozen-lockfile; pnpm run build` ✓
- All necessary environment variables are set ✓

## Summary

The main improvements are:

1. **Branching Strategy** - Use `integration` branch as buffer
2. **Enhanced Scripts** - Better detection of issues
3. **Build Testing** - Verify before deploying
4. **Rollback Plan** - Quick recovery from failures
5. **Clear Process** - Step-by-step workflow

This prevents build failures from reaching production and gives you confidence when merging from upstream.

---

**Questions or concerns?** Review this document and let me know which parts you'd like to implement first.
