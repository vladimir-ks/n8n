---
metadata:
  status: DRAFT
  modules: [consolidation, aigile]
  tldr: "Gaps and flags captured during W3 n8n-render consolidation run"
  dependencies: []
  code_refs: []
---

# Consolidation run gaps — 2026-06-26

## GAP-01: untracked potential-PII PDF
- **Path**: `packages/frontend/editor-ui/public/20251029-P25CON050304978.pdf`
- **Phase**: secrets-gate / discovery
- **Severity**: medium
- **Description**: Untracked file with legal-document-style filename in public frontend dir. Not in git history. Could be a legal/tax/government document accidentally dropped here.
- **Fix**: Owner to inspect + decide: delete if irrelevant, or gitignore + move to `_private_docs/` if sensitive. Already added to `.gitignore` as precaution.
- **Status**: flagged, gitignored, pending owner review

## GAP-02: aigile init auto-sets shadow:true on brownfield fork
- **Phase**: init
- **Severity**: low (known, documented in AIGILE-BRIEF)
- **Description**: `aigile init` sets `shadow: true` on any brownfield repo including owned forks. Requires manual flip to `shadow: false`.
- **Fix-in-tool**: Flag to suppress auto-shadow when profile=venture-repo or when called with `--shadow false`
- **Status**: fixed manually in this run (config.yaml patched)

## GAP-03: aigile init blanket-gitignores `.aigile/`
- **Phase**: init
- **Severity**: low
- **Description**: `aigile init` appends `.aigile/` (blanket) to `.gitignore`, making the entire scaffold uncommittable. Correct behavior is to scope to `aigile.db` + `ai-logs/`.
- **Fix-in-tool**: Init should append scoped entries rather than the dir wildcard, or respect an existing `.aigileignore`
- **Status**: fixed manually in this run (.gitignore updated, _private/ entry added)

## GAP-04: fork ownership classification
- **Phase**: planning
- **Severity**: low
- **Description**: AIGILE has no native concept of "fork-with-owned-additions" — only own vs shadow. n8n-render is a fork where custom docs are owned and should be consolidated, but base code is upstream.
- **Fix-in-tool**: Add `repo_type: fork-owned-additions` profile variant or config field
- **Status**: handled via shadow:false + 55_code-map index; no tooling change needed immediately
