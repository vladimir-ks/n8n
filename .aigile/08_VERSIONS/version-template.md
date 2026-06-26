---
metadata:
  status: TEMPLATE
  version: "1.0"
  tldr: "Version release template"
  title: "Version {X.Y.Z}"
  modules: [versions]
  authors: []
  dependencies: []
release:
  version: "{X.Y.Z}"
  release_date: "{YYYY-MM-DD}"
  status: "planned"
  type: "major|minor|patch"
---

# Version {X.Y.Z}

## Release Date

{YYYY-MM-DD}

## Features

| Story Key | Description |
|-----------|-------------|
| STORY-{KEY} | {Feature description} |

## Bug Fixes

| Bug Key | Description |
|---------|-------------|
| BUG-{KEY} | {Bug fix description} |

## Breaking Changes

- {Breaking change 1}
- {Breaking change 2}

## Migration Guide

{If breaking changes exist, explain how to migrate}

## Deployment Notes

{Any special deployment considerations}

## Rollback Plan

{How to rollback if issues occur}
