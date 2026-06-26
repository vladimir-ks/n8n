---
metadata:
  status: TEMPLATE
  version: "1.0"
  tldr: "API contract template"
  title: "{API Name} API"
  modules: [api]
  authors: []
  dependencies: ["../01_domain-models/"]
---

# {API Name} API

## Overview

{What does this API do? Who uses it?}

## Authentication

{Auth method: OAuth, API key, JWT, etc.}

## Endpoints

### {HTTP Method} /{path}

**Purpose:** {What this endpoint does}

**Request:**
```
{
  "field": "value"
}
```

**Response:**
```
{
  "field": "value"
}
```

**Errors:**
- `400` - {Bad request scenarios}
- `401` - {Unauthorized scenarios}

## Rate Limiting

{Rate limits if applicable}
