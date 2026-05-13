# Contract: Install Safety Gate

**ID:** 0002
**Status:** active
**Created:** 2026-05-12
**Last reviewed:** 2026-05-12
**Last modified:** 2026-05-12

## Statement

The install script must refuse with a clear, actionable error message and exit non-zero whenever any of three preconditions fail: (a) the target directory exists and is writable, (b) the target directory is inside a git repo, (c) if `.verification/` already exists in the target, explicit user confirmation is obtained before proceeding.

## Why it exists

The script writes files into arbitrary directories on users' machines. Without a safety gate, a mis-typed path could write into an unrelated directory, a non-git directory would receive framework files with no version-control safety net, and an existing `.verification/` could be silently overwritten — destroying institutional memory that cannot be recovered without `git`. Each of these failure modes affects the user's project, not ours.

## Scorecard

- **Criticality:** high
  - *Justification:* Violation silently corrupts a user's project or writes to unintended locations with no recovery path except `git checkout`
- **LLM confidence:** high
  - *Justification:* Requirements are precisely stated and the logic is well-understood
- **Parallelization value:** med
  - *Justification:* All subsequent script operations depend on this gate passing correctly; locking this down unblocks confident development of copy/delete logic
- **Surface type:** state-mutating
- **Reversibility:** irreversible

## Human review

- **Required:** yes
- **Reason:** criticality=high; reversibility=irreversible; state-mutating + criticality=high
- **Reviewed by:** matteomelani
- **Reviewed on:** 2026-05-12
- **Outcome:** approved

## Verification

- **Tests:**
  - `test/install_test.sh::test_missing_target` — exits non-zero when target dir does not exist
  - `test/install_test.sh::test_non_writable_target` — exits non-zero when target dir is not writable
  - `test/install_test.sh::test_non_git_target` — exits non-zero when target is not inside a git repo
  - `test/install_test.sh::test_overwrite_prompt_abort` — exits non-zero when user declines overwrite
  - `test/install_test.sh::test_overwrite_prompt_confirm` — proceeds when user confirms overwrite
- **Evals:** n/a
- **Method:** integration
- **Coverage of this contract:** 100% (all three branches covered)

## Mode-specific requirements

- **Spike:** none beyond default
- **Product:** default
- **Infrastructure:** adversarial test required — at least one test attempts to bypass each check (e.g., symlink attack on target path, writable check on parent but not target)

## Related

- **Depends on:** n/a
- **Depended on by:** contracts/0003-install-file-copy-completeness.md, contracts/0004-install-example-deletion-precision.md, contracts/0005-install-mode-prompt.md
- **Related ADRs:** decisions/0002-add-install-script.md

## History

- 2026-05-12: created. Initial scorecard: high / high / med / state-mutating / irreversible.
