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

These files are protected during merges using `.gitattributes`:

```
packages/frontend/editor-ui/vite.config.mts merge=ours
packages/@n8n/codemirror-lang-sql/package.json merge=ours
.gitignore merge=ours
```

This ensures that during merges, our local versions of these files are preserved.

## Verification

After any merge from upstream, run:

```bash
./scripts/verify-custom-fixes.sh
```

This will check that all custom fixes are still present. If any are missing, you can restore them using:

```bash
./scripts/restore-custom-fixes.sh
```

## Adding New Custom Fixes

If you add a new custom deployment fix:

1. Document it in this file
2. Add the file to `.gitattributes` with `merge=ours`
3. Update `scripts/verify-custom-fixes.sh` to check for it
4. Commit with a clear message indicating it's a custom deployment fix

## Merge Workflow

When merging upstream changes:

1. **Before merging:**
   ```bash
   git fetch upstream
   git checkout master
   ```

2. **Merge with strategy:**
   ```bash
   git merge upstream/master --no-edit
   ```
   The `.gitattributes` will automatically preserve our custom fixes.

3. **After merging:**
   ```bash
   ./scripts/verify-custom-fixes.sh
   ```
   If any fixes are missing, restore them and commit.

4. **Push:**
   ```bash
   git push origin master
   ```

