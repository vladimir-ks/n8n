---
metadata:
  status: TEMPLATE
  version: "1.0"
  tldr: "Critical path smoke test"
  title: "Critical Path"
  modules: [smoke-tests]
  authors: []
  dependencies: []
---

Feature: {Critical Business Flow}

  Background:
    Given {initial system state}

  Scenario: {Happy path scenario}
    Given {precondition}
    When {user action}
    Then {expected outcome}

  Scenario: {Edge case scenario}
    Given {precondition}
    When {user action}
    Then {expected outcome}
