# Contract: Example — settlement is idempotent

**ID:** 0001
**Status:** proposed
**Created:** 2026-01-01
**Last reviewed:** n/a
**Last modified:** 2026-01-01

> **Note:** This is an example contract included in the template. Delete or replace it when you start your project. It exists to show the schema in use.

## Statement

The settlement function for a financial transaction produces exactly one ledger entry per transaction ID, regardless of how many times it is invoked.

## Why it exists

Distributed systems retry. Networks fail. Operators run scripts twice. If settlement is not idempotent, retries can double-pay users, create phantom transactions, or corrupt the ledger. Once a duplicate ledger entry exists in production, reconciling it is expensive, slow, and customer-visible. Idempotency at the function boundary prevents the entire class of problem.

## Scorecard

- **Criticality:** high
  - *Justification:* Violation produces irreversible financial state corruption. Detection after the fact requires manual reconciliation.
- **LLM confidence:** high
  - *Justification:* Idempotency is a well-defined property; the test is straightforward (call N times, assert N=1 ledger entry).
- **Parallelization value:** high
  - *Justification:* Once this contract is locked down, retry logic, queue workers, and recovery scripts can be developed independently against the same guarantee.
- **Surface type:** state-mutating
- **Reversibility:** irreversible

## Human review

- **Required:** yes
- **Reason:** Criticality is high AND surface type is state-mutating AND reversibility is irreversible. Three triggers.
- **Reviewed by:** n/a
- **Reviewed on:** n/a
- **Outcome:** pending

## Verification

- **Tests:**
  - `tests/settlement/test_idempotency.py::test_double_invocation_produces_one_entry` — calls settle() twice with the same transaction ID and asserts a single ledger entry exists.
  - `tests/settlement/test_idempotency.py::test_concurrent_invocation_produces_one_entry` — invokes settle() in parallel threads with the same transaction ID; asserts atomic single-entry outcome.
  - `tests/settlement/test_idempotency_property.py::test_property_n_invocations_one_entry` — property-based test: for any N in [1, 100], N invocations produce exactly one entry.
- **Evals:** n/a
- **Method:** composite (unit + integration + property)
- **Coverage of this contract:** 100% required

## Mode-specific requirements

- **Spike:** Even in spike mode, this contract is non-negotiable because it is irreversible. At minimum, the first unit test is required before merging any settlement code.
- **Product:** Default — all three tests required.
- **Infrastructure:** Default + adversarial test required (e.g., a chaos test that injects network failures mid-settlement and verifies idempotency holds).

## Related

- **Depends on:** n/a
- **Depended on by:** n/a (early example)
- **Related ADRs:** decisions/0001-example-adr.md

## History

- 2026-01-01: Created as template example. Initial scorecard: criticality=high, confidence=high, parallelization=high, surface=state-mutating, reversibility=irreversible.
