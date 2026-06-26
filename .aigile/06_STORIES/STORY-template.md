---
metadata:
  status: TEMPLATE
  version: "1.0"
  tldr: "User story template"
  title: "STORY-{KEY}: {Story Title}"
  modules: []
  authors: []
  dependencies: ["../05_EPICS/EPIC-{KEY}.md"]
story:
  key: "STORY-{KEY}"
  epic_key: "EPIC-{KEY}"
  status: "planned"
  priority: "medium"
  points: 3
  assignee: "{Assignee}"
---

# STORY-{KEY}: {Story Title}

## User Story

**As a** {user type}
**I want** {capability}
**So that** {benefit}

## Acceptance Criteria

- [ ] Given {precondition}, when {action}, then {outcome}
- [ ] Given {precondition}, when {action}, then {outcome}
- [ ] Given {precondition}, when {action}, then {outcome}

## Technical Notes

{Implementation approach, API changes, database changes, etc.}

## Test Plan

- Unit tests: {What to test}
- Integration tests: {What to test}
- Manual QA: {Verification steps}

## Related

- Spec: {Link to 01_SPECS/}
- Feature: {Link to 02_FEATURES/}
- Bug: {Link to 09_BUGS/ if fixing a bug}
