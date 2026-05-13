# Contract: Install File Copy Completeness

**ID:** 0003
**Status:** active
**Created:** 2026-05-12
**Last reviewed:** 2026-05-12
**Last modified:** 2026-05-12

## Statement

Every successful installation must produce exactly the required file set in the target: `.verification/` (complete directory tree), `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, and `.github/copilot-instructions.md` — no required file omitted, no extra root-level files added.

## Why it exists

A partial copy produces a silently broken verification setup. If `CLAUDE.md` is missing, Claude Code won't load the operating contract. If `.verification/_meta/PROMPT.md` is missing, no agent will find the methodology. Users installing this framework typically don't know enough about it yet to diagnose a partial install — they'll just conclude the framework doesn't work. Because this script is the primary distribution path for the framework, a copy bug here affects every downstream adopter.

## Scorecard

- **Criticality:** high
  - *Justification:* A partial copy silently breaks the framework for the installing user; they have no way to know which files are missing
- **LLM confidence:** high
  - *Justification:* The required file list is explicitly enumerated in the requirements
- **Parallelization value:** med
  - *Justification:* Downstream users depend on this contract; locking it down enables confident ecosystem growth
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
  - `test/install_test.sh::test_all_required_files_present` — asserts each required path exists after install
  - `test/install_test.sh::test_verification_dir_complete` — asserts `.verification/` subtree matches source (spot-checks key files: `_meta/PROMPT.md`, `_meta/SCHEMA.md`, `README.md`, `MODE.md`, `INVARIANTS.md`)
  - `test/install_test.sh::test_github_dir_created` — asserts `.github/copilot-instructions.md` is present even when `.github/` did not exist before install
- **Evals:** n/a
- **Method:** integration
- **Coverage of this contract:** 100%

## Mode-specific requirements

- **Spike:** none beyond default
- **Product:** default
- **Infrastructure:** property-based test — generate random subsets of the required file list, confirm script produces the full set regardless of pre-existing state

## Related

- **Depends on:** contracts/0002-install-safety-gate.md
- **Depended on by:** contracts/0004-install-example-deletion-precision.md
- **Related ADRs:** decisions/0002-add-install-script.md

## History

- 2026-05-12: created. Initial scorecard: high / high / med / state-mutating / irreversible.
