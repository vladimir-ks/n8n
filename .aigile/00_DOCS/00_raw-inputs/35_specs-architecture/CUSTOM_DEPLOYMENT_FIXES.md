# Custom Deployment Fixes

This document tracks custom fixes that are specific to this deployment and must be preserved during upstream merges.

## Why These Fixes Exist

These fixes address deployment-specific issues encountered when deploying n8n to Render.com. They are not part of the upstream n8n repository and must be maintained separately.

## Custom Fixes

### 1. Rolldown Module Resolution Fix
**File:** `packages/frontend/editor-ui/vite.config.mts`

**Issue:** Build fails with "failed to resolve import" errors for `@codemirror` packages when using Rolldown bundler.

**Fix:** Added `dedupe` configuration to force Rolldown to use single versions of `@codemirror` and `@lezer` packages.

**Location in file:**
```typescript
resolve: {
    alias,
    // Fix Rolldown module resolution for @codemirror packages
    dedupe: [
        '@codemirror/autocomplete',
        '@codemirror/commands',
        '@codemirror/language',
        '@codemirror/lint',
        '@codemirror/search',
        '@codemirror/state',
        '@codemirror/view',
        '@lezer/common',
        '@lezer/highlight',
        '@lezer/lr',
    ],
},
```

**Commit:** `ee0940e787` - "Fix Rolldown module resolution for @codemirror packages"

---

### 2. Missing @lezer/common Dependency
**File:** `packages/@n8n/codemirror-lang-sql/package.json`

**Issue:** Upstream n8n bug - `@n8n/codemirror-lang-sql` imports `@lezer/common` but doesn't list it in dependencies, causing build errors.

**Fix:** Added `"@lezer/common": "^1.0.0"` to dependencies.

**Location in file:**
```json
"dependencies": {
    "@codemirror/autocomplete": "^6.0.0",
    "@codemirror/language": "^6.0.0",
    "@codemirror/state": "^6.0.0",
    "@lezer/common": "^1.0.0",  // <-- This line must be present
    "@lezer/highlight": "^1.0.0",
    "@lezer/lr": "^1.0.0",
    "@n8n/codemirror-lang": "workspace:*"
}
```

**Commit:** `ff76f9f52c` - "Fix missing @lezer/common dependency in codemirror-lang-sql"

---

### 3. Private Files in .gitignore
**File:** `.gitignore`

**Issue:** Private backup and documentation directories should not be committed.

**Fix:** Added entries to ignore private directories.

**Location in file:**
```
# Private files
_backups/
_private_docs/
```

**Commit:** `93cb955ba7` - "chore: hide private docs and backups"

---

## Merge Protection

These files contain critical deployment fixes. The merge process is managed by the `./scripts/merge-upstream.sh` script to ensure they are not overwritten. The script facilitates a manual merge for these files so that upstream changes can be integrated while preserving our custom fixes.

## Verification

After any merge from upstream, the `merge-upstream.sh` script automatically runs the verification script:

```bash
./scripts/verify-custom-fixes.sh
```

This will check that all custom fixes are still present. If any are missing, the merge script will attempt to restore them automatically using:

```bash
./scripts/restore-custom-fixes.sh
```
This script uses patches to re-apply only our custom changes.

**IMPORTANT:** After restoring custom fixes, the script automatically runs `pnpm install --lockfile-only` to update the `pnpm-lock.yaml` file. This ensures that the lockfile stays in sync with any package.json modifications, preventing frozen-lockfile errors during deployment.

## Adding New Custom Fixes

If you add a new custom deployment fix:

1. Document it in this file.
2. Create a patch for your change and add it to `scripts/patches/`.
   - `git diff <commit-before> <commit-with-fix> -- path/to/file > scripts/patches/my-fix-name.patch`
3. Update `scripts/restore-custom-fixes.sh` to apply the new patch.
4. Update `scripts/verify-custom-fixes.sh` to check for the new fix.
5. Add the file path to the `PROTECTED_FILES` array in `scripts/merge-upstream.sh`.
6. Commit with a clear message indicating it's a custom deployment fix.

## Recommended Merge Workflow

**Always use the merge helper script.** This is the safest way to merge.

```bash
./scripts/merge-upstream.sh
```

This script will:
1.  Run pre-flight checks.
2.  Verify your custom fixes are in place.
3.  Fetch upstream changes and warn you if protected files have changed.
4.  Attempt the merge.
5.  If there are conflicts, it will pause and let you resolve them.
6.  Automatically restore and verify your custom fixes.
7.  Stage all changes, ready for you to review and commit.

This process ensures you never miss important upstream updates to your protected files while guaranteeing your custom fixes are always preserved.

