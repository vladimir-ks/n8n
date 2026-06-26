---
metadata:
  status: IN-REVIEW
  modules: [infra, deployment, n8n]
  tldr: "Code/config/data pointer index for n8n-render-deployment (fork of n8n-io/n8n with custom Render.com deployment additions)"
  dependencies: []
  code_refs:
    - packages/
    - scripts/
    - docker/
    - n8n-local-prod-docker-deploy/
    - patches/
---

# n8n-render: Code Map

Fork of [n8n-io/n8n](https://github.com/n8n-io/n8n) with custom deployment additions for Render.com.
Origin: `git@github.com:vladimir-ks/n8n.git`

## Repository structure

| Path | Type | Description |
|---|---|---|
| `packages/` | upstream code | n8n monorepo (TypeScript/Vue 3; ~53K commits upstream) |
| `packages/frontend/editor-ui/` | upstream+patch | Frontend; patched: `vite.config.mts` (Rolldown dedupe fix) |
| `packages/@n8n/codemirror-lang-sql/` | upstream+patch | patched: `package.json` (@lezer/common dep fix) |
| `scripts/` | owned code | Merge/build/verify shell+mjs scripts |
| `scripts/merge-upstream.sh` | owned | Safe upstream merge driver |
| `scripts/merge-upstream-safe.sh` | owned | Integration-branch merge workflow |
| `scripts/verify-custom-fixes.sh` | owned | Post-merge fix verification |
| `scripts/restore-custom-fixes.sh` | owned | Patch restore after upstream merge |
| `scripts/patches/` | owned | Git patches for custom fixes |
| `docker/` | owned | Custom docker images |
| `n8n-local-prod-docker-deploy/` | owned | Docker Compose deployment kit |
| `n8n-local-prod-docker-deploy/docker-compose.yaml.template` | config | Compose template |
| `n8n-local-prod-docker-deploy/Dockerfile` | config | Custom n8n Dockerfile |
| `n8n-local-prod-docker-deploy/nginx.conf.template` | config | Nginx reverse proxy template |
| `n8n-local-prod-docker-deploy/setup.sh.template` | config | Setup script template |
| `n8n-local-prod-docker-deploy/backup.sh` | script | Backup script |
| `n8n-local-prod-docker-deploy/backup-to-gdrive.sh` | script | GDrive backup script |
| `n8n-local-prod-docker-deploy/n8n-watchdog.sh` | script | Health monitor/restart |
| `n8n-local-prod-docker-deploy/monitor-workflow.json` | data | n8n monitoring workflow |
| `patches/` | owned | Additional patch files |
| `local-prod-docker-deploy-n8n.sh` | script | Top-level deploy entrypoint |
| `volumes/` | data | Docker volume mount (empty; gitignored content) |
| `_backups/` | data | Encrypted backup archives (gitignored) |
| `assets/` | media | Screenshots + n8n logo (also copied to 40_media/) |

## Custom patches (preserved across upstream merges)
| Fix | File | Commit |
|---|---|---|
| Rolldown dedupe for @codemirror | `packages/frontend/editor-ui/vite.config.mts` | `ee0940e787` |
| @lezer/common dep | `packages/@n8n/codemirror-lang-sql/package.json` | `ff76f9f52c` |
| .gitignore private dirs | `.gitignore` | `93cb955ba7` |

## Deployment
- **Platform**: Render.com (watches `master` branch on `vladimir-ks/n8n`)
- **Build**: `pnpm install --frozen-lockfile; pnpm run build`
- **Node**: 22.16
- **Upstream**: `git@github.com:n8n-io/n8n.git`
- **Merge workflow**: always use `scripts/merge-upstream.sh` (never `git merge -X theirs`)

## Untracked / pending review
- `packages/frontend/editor-ui/public/20251029-P25CON050304978.pdf` — untracked; potential PII; needs owner review before any commit
