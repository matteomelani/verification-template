# ADR 0001: Example — adopt verification-first methodology

**Status:** accepted
**Date:** 2026-01-01
**Deciders:** [project owner], LLM agent
**Supersedes:** n/a
**Superseded by:** n/a

> **Note:** This is an example ADR included in the template. Delete or replace it when you start your project. It exists to show the schema in use.

## Context

The project is starting from scratch. We need to decide how verification (testing, eval baselines, contract documentation) will be approached. Two broad options exist:

1. **Traditional**: write code first, add tests as time permits, document only when forced.
2. **Verification-first**: extract requirements before designing, name contracts before coding, require tests with every change.

Option 1 is the industry default. It produces codebases where test coverage is patchy, regressions are common, and institutional memory lives only in senior engineers' heads.

Option 2 is the rarer approach used in avionics, medical devices, and a small number of high-reliability software shops. Historically it has been expensive because writing comprehensive tests required sustained human willpower.

The arrival of capable AI coding agents (Claude, Codex, etc.) changes the cost equation: the effort wall that made option 2 expensive has collapsed. Agents do not get bored writing edge-case tests. They do not cut corners on Friday afternoon.

## Decision

Adopt the verification-first methodology for this project, with mode-aware enforcement (spike / product / infrastructure) and an LLM operating contract documented in `.verification/_meta/PROMPT.md`.

## Rationale

The marginal cost of writing tests with an LLM is near zero. The marginal cost of *not* writing them is the same as it has always been: regressions, lost institutional memory, fear of changing code. Given that the cost ratio has flipped, the optimal strategy is to invest heavily in verification from day one.

Mode-aware enforcement preserves flexibility: a spike does not need property-based tests and adversarial evals. But the methodology still applies in spike mode for documentation, so that when a spike graduates, the verification work is half-done.

## Alternatives considered

- **Traditional "tests later" approach.** Rejected because the historical reason for it (test-writing is expensive human labor) no longer applies. Choosing it now would be optimizing for a constraint that no longer exists.
- **Test-driven development (TDD) without scorecards.** Rejected because TDD does not provide a mechanism to triage which contracts deserve heavy investment. The scorecard adds that triage without sacrificing the core TDD idea.
- **External test consultancy.** Rejected as overkill for the current scale and irrelevant to the agent-driven workflow.

## Consequences

### Positive

- Verification thinking is embedded in every design conversation, not bolted on later.
- Institutional memory accumulates in `.verification/` files that survive personnel turnover.
- The LLM has a clear protocol for when to ask for human review, reducing decision fatigue.
- Mode transitions (spike → product → infrastructure) are explicit and trigger scorecard re-review.

### Negative

- Sessions are slightly slower upfront because verification planning happens before design.
- The `.verification/` folder adds maintenance overhead (small, but non-zero).
- Requires discipline to prevent the folder from becoming stale.

### Neutral

- Other dev tools (Cursor, Codex, Copilot) need to be configured to read `.verification/_meta/PROMPT.md`. This is a one-time setup cost via small pointer files at the project root.

## Verification impact

- Contracts created: contracts/0001-example-settlement-idempotency.md (example)
- Contracts modified: n/a
- Contracts deprecated: n/a
