---
metadata:
  status: TEMPLATE
  version: "1.0"
  tldr: "Feature file template"
  title: "{Feature Name}"
  modules: []
  authors: []
  dependencies: []
---

Feature: {Feature Name}
  {Brief description of feature value}

  Background:
    Given {common preconditions}

  Scenario: {Scenario name}
    Given {precondition}
    When {action}
    Then {outcome}
    And {additional outcome}

  Scenario Outline: {Parameterized scenario}
    Given {precondition with <parameter>}
    When {action with <parameter>}
    Then {outcome with <parameter>}

    Examples:
      | parameter | expected_result |
      | value1    | result1         |
      | value2    | result2         |
