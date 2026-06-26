# _provenance.md — n8n-render-deployment
# Consolidation run: 2026-06-26 (W3 group-C)

## Source → Destination map

### 35_specs-architecture/
| Source (repo-relative) | Destination | Notes |
|---|---|---|
| `DEPLOY.md` | `.aigile/00_DOCS/00_raw-inputs/35_specs-architecture/DEPLOY.md` | Custom deployment guide (Render.com) |
| `CUSTOM_DEPLOYMENT_FIXES.md` | `.aigile/00_DOCS/00_raw-inputs/35_specs-architecture/CUSTOM_DEPLOYMENT_FIXES.md` | ADR for upstream merge patches |
| `n8n-local-prod-docker-deploy/README.md` | `.aigile/00_DOCS/00_raw-inputs/35_specs-architecture/n8n-local-prod-docker-deploy-README.md` | Local prod Docker deploy guide |
| `n8n-local-prod-docker-deploy/ENVIRONMENT_VARIABLES.md` | `.aigile/00_DOCS/00_raw-inputs/35_specs-architecture/n8n-local-prod-docker-deploy-ENVIRONMENT_VARIABLES.md` | Env var reference for deploy kit |

### 45_decision-logs/
| Source | Destination | Notes |
|---|---|---|
| `MERGE_WORKFLOW_RECOMMENDATIONS.md` | `.aigile/00_DOCS/00_raw-inputs/45_decision-logs/MERGE_WORKFLOW_RECOMMENDATIONS.md` | Merge workflow decision + recommendations |
| `n8n-local-prod-docker-deploy/PROJECT_STATUS.md` | `.aigile/00_DOCS/00_raw-inputs/45_decision-logs/n8n-local-prod-docker-deploy-PROJECT_STATUS.md` | Deploy kit project status log |

### 40_media/
| Source | Destination | Notes |
|---|---|---|
| `assets/n8n-logo.png` | `.aigile/00_DOCS/00_raw-inputs/40_media/n8n-logo.png` | n8n logo (copy; original kept for README reference) |
| `assets/n8n-screenshot.png` | `.aigile/00_DOCS/00_raw-inputs/40_media/n8n-screenshot.png` | n8n instance screenshot |
| `assets/n8n-screenshot-readme.png` | `.aigile/00_DOCS/00_raw-inputs/40_media/n8n-screenshot-readme.png` | README screenshot |

### _private/ (gitignored)
| Source | Destination | Notes |
|---|---|---|
| `_private_docs/GOOGLE_SAFE_BROWSING_REVIEW.md` | `.aigile/00_DOCS/00_raw-inputs/_private/GOOGLE_SAFE_BROWSING_REVIEW.md` | Security review (copy; original gitignored) |
| `_private_docs/HETZNER_MIGRATION_PLAN.md` | `.aigile/00_DOCS/00_raw-inputs/_private/HETZNER_MIGRATION_PLAN.md` | Migration plan (copy) |
| `_private_docs/REMEDIATION_ACTION_PLAN.md` | `.aigile/00_DOCS/00_raw-inputs/_private/REMEDIATION_ACTION_PLAN.md` | Security remediation (copy) |
| `_private_docs/SECURITY_INVESTIGATION_REPORT.md` | `.aigile/00_DOCS/00_raw-inputs/_private/SECURITY_INVESTIGATION_REPORT.md` | Security investigation (copy) |
| `_private_docs/SESSION_SUMMARY.md` | `.aigile/00_DOCS/00_raw-inputs/_private/SESSION_SUMMARY.md` | Session log (copy) |
| `_private_docs/TODO.md` | `.aigile/00_DOCS/00_raw-inputs/_private/TODO.md` | Private todo (copy) |
| `_private_docs/backup-n8n-data.sh` | `.aigile/00_DOCS/00_raw-inputs/_private/backup-n8n-data.sh` | Backup script (copy) |

### 55_code-map/
| Source | Destination | Notes |
|---|---|---|
| (code stays in place) | `.aigile/00_DOCS/00_raw-inputs/55_code-map/n8n-render-code-index.md` | Pointer index only; no code moved |

## Left in place (upstream/build-critical — not moved)
- `README.md`, `CHANGELOG.md`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`
- `LICENSE.md`, `LICENSE_EE.md`, `CONTRIBUTOR_LICENSE_AGREEMENT.md`
- `CLAUDE.md` (active), `packages/frontend/CLAUDE.md` (active)
- All build configs: `package.json`, `pnpm-lock.yaml`, `pnpm-workspace.yaml`, `turbo.json`, etc.
- `scripts/`, `docker/`, `n8n-local-prod-docker-deploy/` (configs/code), `patches/`, `packages/`

## Secrets/PII status
- `.env` (live N8N_ENCRYPTION_KEY) — gitignored; never committed; NOT moved
- `_private_docs/` — gitignored at source; copies in `.aigile/00_DOCS/00_raw-inputs/_private/` (also gitignored)
- `packages/frontend/editor-ui/public/20251029-P25CON050304978.pdf` — untracked, potential PII; flagged for owner review

## Project classification
- Type: fork (upstream n8n-io/n8n) with custom deployment additions
- Shadow: false (custom docs are owned, actively consolidated)
- gitea remote: pending (W5)
