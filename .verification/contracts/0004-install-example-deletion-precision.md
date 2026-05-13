# Contract: Install Example Deletion Precision

**ID:** 0004
**Status:** active
**Created:** 2026-05-12
**Last reviewed:** 2026-05-12
**Last modified:** 2026-05-12

## Statement

After copying, the script must delete exactly `contracts/0001-example-settlement-idempotency.md` and `decisions/0001-example-adopt-verification-first.md` from the target's `.verification/` folder, and must not delete any other files.

## Why it exists

The example files exist in the template only to demonstrate the contract and ADR schemas. If left in the target, they confuse future LLMs and humans — the LLM may load them as real contracts and derive false invariants. Conversely, if the deletion logic uses a glob or recursive delete, it risks destroying real contracts the user has already written (particularly important on the overwrite path). Because deletions in someone else's project are irreversible without `git`, the precision requirement is non-negotiable.

## Scorecard

- **Criticality:** high
  - *Justification:* Deleting the wrong files destroys user data; leaving examples in place causes silent correctness failures in LLM reasoning
- **LLM confidence:** med
  - *Justification:* The specific filenames are given, but the "must not delete anything else" constraint requires careful scripting — one misplaced glob or wildcard deletes a directory
- **Parallelization value:** low
  - *Justification:* Isolated cleanup step with no downstream dependents
- **Surface type:** state-mutating
- **Reversibility:** irreversible

## Human review

- **Required:** yes
- **Reason:** criticality=high; LLM confidence=med; reversibility=irreversible; state-mutating + criticality=high
- **Reviewed by:** matteomelani
- **Reviewed on:** 2026-05-12
- **Outcome:** approved

## Verification

- **Tests:**
  - `test/install_test.sh::test_examples_deleted` — asserts both example files are absent after install
  - `test/install_test.sh::test_no_other_files_deleted` — asserts all other `.verification/` files are present after install (exhaustive file list check)
  - `test/install_test.sh::test_deletion_idempotent` — asserts second install (overwrite path) does not error even if examples are already absent
- **Evals:** n/a
- **Method:** integration
- **Coverage of this contract:** 100%

## Mode-specific requirements

- **Spike:** none beyond default
- **Product:** default
- **Infrastructure:** adversarial test — plant extra files in `contracts/` and `decisions/` before install, confirm they survive

## Related

- **Depends on:** contracts/0003-install-file-copy-completeness.md
- **Depended on by:** n/a
- **Related ADRs:** decisions/0002-add-install-script.md

## History

- 2026-05-12: created. Initial scorecard: high / med / low / state-mutating / irreversible.
