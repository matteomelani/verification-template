# Schema Reference

This file defines the structure of every file in `.verification/`. Any LLM or tool reading or writing to this folder must conform to these schemas. Drift is the enemy.

If you need to evolve a schema, do it via an ADR (`.verification/decisions/`) and update this file in the same change.

---

## File: `MODE.md`

A single line indicating the project mode.

**Valid values:** `spike` | `product` | `infrastructure`

**Example:**

```
product
```

No other content. Comments allowed on subsequent lines starting with `#`.

---

## File: `CONFIG.md`

Per-mode overrides for thresholds and rules. Optional — if absent, defaults from `_meta/PROMPT.md` apply.

**Structure:**

```markdown
# Project Verification Config

## Mode overrides

### Coverage thresholds
- Spike: <number or "n/a">
- Product: <number>
- Infrastructure: <number>

### Eval requirements
- Spike: <required | optional | n/a>
- Product: <required | optional | n/a>
- Infrastructure: <required | optional | n/a>

## Project-specific axes

<Add any project-specific scorecard axes here, with rationale.>

## Notes

<Anything else specific to this project.>
```

---

## File: `INVARIANTS.md`

The canonical list of project-level invariants. These are system-wide
guarantees the system must always hold or must never violate. They are
typically derived from the union of all `high` criticality contracts, but may
also include cross-cutting rules.

**Structure:**

```markdown
# Project Invariants

Format: each invariant has an ID, a one-sentence statement, and a link to the contract(s) that enforce it.

## INV-001: <one-sentence statement>
- Enforced by: contracts/0001-name.md, contracts/0007-name.md
- Why it exists: <one paragraph>

## INV-002: ...
```

---

## File: `contracts/NNNN-slug.md`

One file per contract. Numbered with 4-digit zero-padded IDs (`0001`, `0002`, ...). Slug is kebab-case.

**Required structure:**

```markdown
# Contract: <human-readable name>

**ID:** <NNNN>
**Status:** proposed | active | deprecated | superseded
**Created:** YYYY-MM-DD
**Last reviewed:** YYYY-MM-DD
**Last modified:** YYYY-MM-DD

## Statement

<One sentence. The contract itself. State what the system must always do, never do, or guarantee under specific conditions.>

## Why it exists

<2–4 sentences. What goes wrong if this contract is violated? What was the impetus for adding it (incident, design discussion, foresight)?>

## Scorecard

- **Criticality:** low | med | high
  - *Justification:* <one line>
- **LLM confidence:** low | med | high
  - *Justification:* <one line>
- **Parallelization value:** low | med | high
  - *Justification:* <one line>
- **Surface type:** state-mutating | pure | presentation
- **Reversibility:** reversible | irreversible

## Human review

- **Required:** yes | no
- **Reason:** <if yes, which escalation rule fired>
- **Reviewed by:** <name or n/a>
- **Reviewed on:** YYYY-MM-DD or n/a
- **Outcome:** approved | approved-with-changes | rejected | pending

## Verification

- **Tests:**
  - `path/to/test_file.py::test_name` — <what it verifies>
  - (one or more, or "none-yet" with a deadline if in spike mode)
- **Evals:**
  - `.verification/evals/<folder>/` (if applicable, else "n/a")
- **Method:** unit | integration | property | TTY | manual | eval | composite
- **Coverage of this contract:** <percentage or "n/a">

## Mode-specific requirements

What this contract requires in each mode. Use this section to record overrides.

- **Spike:** <what's required, or "none beyond default">
- **Product:** <what's required, or "default">
- **Infrastructure:** <what's required, or "default">

## Related

- **Depends on:** contracts/NNNN-other.md (if any)
- **Depended on by:** contracts/NNNN-other.md (if any)
- **Related ADRs:** decisions/NNNN-name.md (if any)

## History

- YYYY-MM-DD: created. Initial scorecard: <scores>.
- YYYY-MM-DD: <change>. Reason: <reason>.
```

---

## File: `decisions/NNNN-slug.md`

Architecture Decision Records (ADRs). One file per non-obvious decision. Standard ADR format.

**Required structure:**

```markdown
# ADR <NNNN>: <title>

**Status:** proposed | accepted | superseded | deprecated
**Date:** YYYY-MM-DD
**Deciders:** <names>
**Supersedes:** decisions/NNNN-name.md (if applicable)
**Superseded by:** decisions/NNNN-name.md (if applicable)

## Context

<What is the problem? What forces are at play? Why does this decision need to be made now?>

## Decision

<What is the change? State it clearly and concretely.>

## Rationale

<Why this option, not the alternatives? What tradeoffs did we accept?>

## Alternatives considered

- **Option A:** <description>. Rejected because <reason>.
- **Option B:** <description>. Rejected because <reason>.

## Consequences

### Positive
- <what gets better>

### Negative
- <what we pay>

### Neutral
- <what changes but isn't strictly better or worse>

## Verification impact

- Contracts created: contracts/NNNN-name.md
- Contracts modified: contracts/NNNN-name.md
- Contracts deprecated: contracts/NNNN-name.md
```

---

## Folder: `evals/<surface-name>/`

One folder per non-deterministic surface (LLM call, ranking algorithm, fuzzy matcher, recommender, etc.).

**Required files:**

- `README.md` — describes what's being evaluated, what the rubric is, and how to run it.
- `baseline.md` — the canonical baseline scores. Updated only when a deliberate baseline shift is approved.
- `vN-results.json` or `vN-results.md` — results from each version. Numbered sequentially.

**Suggested structure of `baseline.md`:**

```markdown
# Eval baseline: <surface name>

**Last updated:** YYYY-MM-DD
**Updated by:** <name>
**Reason for last update:** <one line>

## Rubric

<What is being scored, on what scale, by whom (or what model).>

## Baseline scores

- Overall: <score>
- <Sub-dimension 1>: <score>
- <Sub-dimension 2>: <score>

## Threshold

A new version must score at least this well to ship:

- Overall: <minimum>
- Critical sub-dimensions: <minimum each>

## Related contracts

- contracts/NNNN-name.md
```

---

## File: `sessions/YYYY-MM-DD-slug.md` (optional)

Rolling log of session summaries. Useful as institutional memory for future LLMs and humans.

**Suggested structure:**

```markdown
# Session: YYYY-MM-DD — <topic>

**Participants:** <names, including the LLM>
**Duration:** <approximate>

## Goal

<What were we trying to accomplish?>

## Decisions made

- <decision 1> — see decisions/NNNN-name.md (if formalized)
- <decision 2>

## Contracts touched

- Created: contracts/NNNN-name.md
- Modified: contracts/NNNN-name.md
- Reviewed: contracts/NNNN-name.md

## Open questions

- <what's unresolved>

## Next session

- <what to pick up>
```

---

## Numbering rules

- IDs are 4-digit zero-padded integers (`0001` through `9999`).
- IDs are never reused. A deprecated contract keeps its ID.
- Each folder (`contracts/`, `decisions/`, `evals/`) has its own numbering sequence.
- The next ID is `max(existing) + 1`. If no files exist, start at `0001`.

---

## File naming rules

- Numbered files: `NNNN-kebab-case-slug.md`
- Slugs are descriptive but short (3–6 words). They are human-readable handles; the ID is the canonical identifier.
- Renaming a slug is allowed but discouraged. If you must rename, leave a note in the file's history section.

---

## Status transitions

### Contracts
- `proposed` → `active`: after human review (if required) and after at least one test exists (in product/infrastructure mode).
- `active` → `deprecated`: when the contract no longer applies. Add a note explaining why. Do not delete the file.
- `active` → `superseded`: when a newer contract replaces it. Link to the successor.

### ADRs
- `proposed` → `accepted`: after the decision is made.
- `accepted` → `superseded`: when a newer ADR overrides it. Link to the successor. Do not delete.
- `accepted` → `deprecated`: when the decision no longer applies but no successor exists.

Files are append-only in spirit. We do not delete history; we mark it as superseded or deprecated and link forward.
