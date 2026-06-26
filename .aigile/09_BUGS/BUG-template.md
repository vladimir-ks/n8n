---
metadata:
  status: TEMPLATE
  version: "1.0"
  tldr: "Bug report template"
  title: "BUG-{KEY}: {Bug Title}"
  modules: []
  authors: []
  dependencies: []
bug:
  key: "BUG-{KEY}"
  severity: "critical|high|medium|low"
  priority: "high|medium|low"
  status: "open"
  reported_by: "{Reporter}"
  assigned_to: "{Assignee}"
  reported_date: "{YYYY-MM-DD}"
---

# BUG-{KEY}: {Bug Title}

## Description

{Clear description of the bug}

## Environment

- Version: {Version where bug occurs}
- Platform: {OS/Browser/Device}
- Environment: {Dev/Staging/Production}

## Steps to Reproduce

1. {Step 1}
2. {Step 2}
3. {Step 3}

## Expected Behavior

{What should happen}

## Actual Behavior

{What actually happens}

## Screenshots/Logs

{Attach screenshots, error logs, stack traces}

## Impact

{How does this affect users?}

## Root Cause

{Analysis of why this bug exists}

## Fix

- Story Key: {STORY-KEY if fix created}
- Fix Description: {How was it fixed}
- Fixed in Version: {Version number}

## Verification

- [ ] Fix verified in dev
- [ ] Fix verified in staging
- [ ] Fix verified in production
