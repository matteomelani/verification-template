# Contract: Install curl|bash Temp Cleanup

**ID:** 0006
**Status:** active
**Created:** 2026-05-12
**Last reviewed:** 2026-05-12
**Last modified:** 2026-05-12

## Statement

When invoked via `curl | bash` (no source directory available), the script must clone the repo to a directory created by `mktemp -d`, register a `trap` to remove that directory on `EXIT` (both success and failure paths), and never leave temp directories behind after the process exits.

## Why it exists

This is the primary advertised installation path. A failure mid-clone or mid-copy that leaves a temp directory behind litters the user's `/tmp`. More critically, a missing `trap` means any `exit` call in an error path (including the safety gate) bypasses cleanup — and since `set -e` is active, any unexpected error silently leaves state. The `trap` must be registered before the clone, not after, or the window between `mktemp` and `trap` leaks on error.

## Scorecard

- **Criticality:** high
  - *Justification:* Primary distribution path; failed cleanup litters the filesystem; partial temp state is difficult for users to find and diagnose
- **LLM confidence:** med
  - *Justification:* The `trap` + `mktemp` pattern is standard but easy to mis-wire (trap must precede mktemp; variable must be initialized before trap registration or the trap body will reference an unset variable under `set -u`)
- **Parallelization value:** low
  - *Justification:* Isolated invocation path
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
  - `test/install_test.sh::test_tmpdir_cleaned_on_success` — after successful install, temp dir is absent
  - `test/install_test.sh::test_tmpdir_cleaned_on_failure` — after a triggered safety-gate failure, temp dir is absent
  - `test/install_test.sh::test_trap_registered_before_clone` — code review / static check: `trap` line appears before `mktemp` line in script
- **Evals:** n/a
- **Method:** integration + static
- **Coverage of this contract:** 100%

## Mode-specific requirements

- **Spike:** none beyond default
- **Product:** default
- **Infrastructure:** adversarial test — send SIGINT mid-clone, confirm cleanup still runs

## Related

- **Depends on:** contracts/0002-install-safety-gate.md
- **Depended on by:** n/a
- **Related ADRs:** decisions/0002-add-install-script.md

## History

- 2026-05-12: created. Initial scorecard: high / med / low / state-mutating / irreversible.
