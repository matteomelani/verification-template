# Contract: README Install Documentation

**ID:** 0007
**Status:** active
**Created:** 2026-05-12
**Last reviewed:** 2026-05-12
**Last modified:** 2026-05-12

## Statement

`README.md` must document the `curl | bash` invocation as the primary installation path, the manual local clone path as secondary, and the existing `cp -r` instructions as a third fallback, in that order of presentation.

## Why it exists

The install script is only useful if people know it exists. The ordering matters: `curl | bash` is the zero-friction path for most adopters; the manual clone path serves users who need to audit the script first; `cp -r` is preserved for offline environments or users who distrust remote execution. Reversing the order buries the easy path and increases adoption friction.

## Scorecard

- **Criticality:** low
  - *Justification:* Incorrect docs mislead users but do not damage their project
- **LLM confidence:** high
  - *Justification:* Requirements are clearly stated
- **Parallelization value:** low
  - *Justification:* Documentation only
- **Surface type:** presentation
- **Reversibility:** reversible

## Human review

- **Required:** no
- **Reason:** no escalation triggers fired
- **Reviewed by:** n/a
- **Reviewed on:** n/a
- **Outcome:** n/a

## Verification

- **Tests:**
  - Manual review: confirm README contains curl|bash block before manual-clone block before cp -r block
- **Evals:** n/a
- **Method:** manual
- **Coverage of this contract:** n/a

## Mode-specific requirements

- **Spike:** none beyond default
- **Product:** default
- **Infrastructure:** default

## Related

- **Depends on:** n/a
- **Depended on by:** n/a
- **Related ADRs:** decisions/0002-add-install-script.md

## History

- 2026-05-12: created. Initial scorecard: low / high / low / presentation / reversible.
