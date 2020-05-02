# Tests Definition and Scope

## Context and Problem Statement

Acceptance tests are embedded into game server application.
Should they be written one layer above (UI)?

## Decision Drivers

* User acceptance tests should be meaningful
* Set a definition and scope for tests

## Decision Outcome

Redefine current acceptance tests and treat them like _component_ tests according to [this definition](https://www.simpleorientedarchitecture.com/defining-test-boundaries/) of boundaries for unit, component and acceptance tests.

* Good, because it promotes different tests for different audiences
* Good, because it sets a clear terminology
* Good, because end users don't care about layers above UI
