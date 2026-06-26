---
metadata:
  status: TEMPLATE
  modules: []
  tldr: "AIGILE frontmatter standard — the metadata block every Markdown doc carries"
  dependencies: []
  code_refs: []
---

# Frontmatter Conventions

Every Markdown file in an AIGILE project (except raw inputs and archives) MUST
open with the standard metadata block. It makes documents machine-readable so
AI agents can index, route, and reason over the repository.

## Standard Block

```yaml
---
metadata:
  status: TEMPLATE # [TEMPLATE|DRAFT|IN-REVIEW|APPROVED|NEEDS-REVIEW]
  modules: []      # Context labels (e.g. [auth, billing])
  tldr: "{SUMMARY}"
  dependencies: [] # Paths to parent/related docs
  code_refs: []    # Paths to source code
---
```

## Field Reference

| Field | Type | Purpose |
|-------|------|---------|
| `status` | enum | Lifecycle stage. Drives review gates. |
| `modules` | string[] | Context labels for cross-cutting search. |
| `tldr` | string | One-line summary. Surfaced in indexes. |
| `dependencies` | string[] | Relative paths to parent/related docs. |
| `code_refs` | string[] | Relative paths to source the doc describes. |

## Rules

1. The block is the first content in the file — nothing precedes the opening `---`.
2. `status` is required; the remaining fields may be empty lists/strings.
3. Use placeholders (`{PLACEHOLDER}`) for values resolved at init time.
4. Raw inputs (`00_raw-inputs/`) and archives (`99_archive/`) are exempt.
