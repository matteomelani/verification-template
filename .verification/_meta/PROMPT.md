# Verification-First Engineering: Operating Contract

You are coding on a project that uses a verification-first methodology. This file is your operating contract. Load it into context at the start of every session. Re-read it whenever you are uncertain about the right behavior.

The methodology is simple to state and hard to follow: **verification is a design input, not a design output.** Tests and contracts are not artifacts you produce after writing code — they are the framework you use to decide what to write in the first place.

---

## The two non-negotiable behaviors

### 1. At design time: verification before architecture

When asked to design any non-trivial software solution, you do **not** start with architecture, libraries, or code. You start by:

1. **Extracting requirements** — both functional ("the system must do X") and behavioral ("the system must never do Y, even under conditions Z").
2. **For each requirement, answering two questions explicitly:**
   - *How will we know this requirement is satisfied?* (Verification method.)
   - *How will we know it stays satisfied as the code evolves?* (Regression strategy.)
3. **Flagging untestable requirements as design risk.** If a requirement cannot be verified, that is not a testing problem — it is a design problem. Surface it and propose either a redesign that makes it testable, or an explicit decision to accept the risk (documented as an ADR).
4. **Producing a verification plan before a design.** The plan lists the contracts the system will need to satisfy, scored on the rubric below. Architecture follows from the contracts, not the other way around.

You only proceed to design and code after the human has reviewed the verification plan.

### 2. At implementation time: contracts before code

Every unit of work — every PR, every feature, every meaningful refactor — must explicitly answer, in dialogue with the human:

- **What contracts am I creating or modifying?** Name them. A contract is a behavioral invariant: a statement of what the system must always do, never do, or guarantee under specific conditions.
- **How will those contracts be tested?** Name the test method (unit, integration, property-based, TTY harness, eval, etc.) and the file/test name.
- **How will the tests survive future changes?** What stops a future PR from silently weakening this contract? (Coverage floor, naming convention, CI rule, etc.)

Code without a named contract is suspect. If you cannot articulate the contract a piece of code enforces, you do not understand the code well enough to ship it.

---

## The scorecard (how contracts are evaluated)

Every contract gets a scorecard. Scorecards are stored in `.verification/contracts/NNNN-name.md`. The scorecard determines how much verification investment a contract warrants and whether human review is required before proceeding.

### Axes

| Axis | Values | What it measures |
|---|---|---|
| **Criticality** | low / med / high | How bad is a violation? Considers blast radius, reversibility, and whether the violation can be detected after the fact. |
| **LLM confidence** | low / med / high | How sure are you (the LLM) that you have correctly identified and scoped this contract? Low confidence triggers human review regardless of criticality. |
| **Parallelization value** | low / med / high | If this contract is locked down with crisp tests, does it enable independent work streams (parallel agents, parallel humans, parallel features)? High parallelization value justifies investment for velocity reasons even on low-criticality contracts. |
| **Surface type** | state-mutating / pure / presentation | State-mutating code gets exhaustive treatment. Pure functions get standard coverage. Presentation gets light coverage. |
| **Reversibility** | reversible / irreversible | Can a violation be un-shipped? Irreversible violations (financial transactions, data deletion, security breaches) get treated as high criticality regardless of other axes. |

### Escalation rule

**Ask the human for review when ANY of the following are true:**

- Criticality is `high`
- Reversibility is `irreversible`
- LLM confidence is `low`
- Surface type is `state-mutating` AND criticality is `med` or `high`

For all other contracts: declare the scorecard in the PR body, write the file to `.verification/contracts/`, and proceed. The human can review and override at any time.

When you ask for review, present the scorecard, your reasoning for each score, and a recommended verification plan. Wait for explicit approval before proceeding.

---

## Mode-aware enforcement

The project mode is declared in `.verification/MODE.md`. Read it at the start of every session. If it is not set, ask the human before proceeding with any substantive work.

There are three modes:

### `spike`

The project is exploratory. The primary goal is learning. The code may be thrown away.

- **What you still do:** Track contracts and scorecards. Write them to `.verification/contracts/` as you would in any mode. This is the institutional memory — when the spike graduates to product mode, the verification work is already half-done.
- **What you relax:** Test enforcement. Tests are optional except for `high` criticality or `irreversible` contracts, which are non-negotiable in any mode. No coverage floor. Evals optional.
- **Dialogue protocol:** Still applies. Ask before doing irreversible things.

### `product`

The project is the basis for something real. Code will be maintained.

- **Tests:** Required for every contract scored `med` criticality or higher. Required for all state-mutating surfaces.
- **Coverage floor:** 80% on business logic; 100% on irreversible surfaces. CI rule: `coverage_delta >= 0` (the floor never drops).
- **Evals:** Required for any non-deterministic surface (LLM calls, ranking, fuzzy matching).
- **Dialogue protocol:** Fully applies per escalation rule above.

### `infrastructure`

The project is foundational. Things downstream depend on it being correct.

- **Tests:** Required for every contract regardless of score.
- **Coverage floor:** 90% on business logic; 100% on irreversible surfaces; property-based tests required for all state-mutating contracts.
- **Evals:** Required for any non-deterministic surface, with versioned baselines and trend tracking.
- **Adversarial testing:** Required. Each high-criticality contract needs at least one test designed to break it.
- **Dialogue protocol:** Fully applies. Additionally, any contract change requires an ADR in `.verification/decisions/`.

---

## File layout you must maintain

All verification artifacts live in `.verification/` at the project root. You read from and write to this folder. Other LLMs and dev environments (Cursor, Codex, Copilot) will read it too — keep it tool-agnostic.

```
.verification/
├── README.md                  ← Human-readable entry point. Do not modify without good reason.
├── MODE.md                    ← One line: spike | product | infrastructure
├── CONFIG.md                  ← Per-mode thresholds and overrides. Read before applying rules.
├── INVARIANTS.md              ← Project-level invariants. Rarely changes.
├── contracts/                 ← One file per contract. Numbered: 0001-name.md
├── decisions/                 ← Architecture Decision Records (ADRs). Numbered: 0001-name.md
├── evals/                     ← One folder per eval surface. Baseline + versioned results.
├── sessions/                  ← Optional: rolling log of session summaries. YYYY-MM-DD-topic.md
└── _meta/
    ├── PROMPT.md              ← This file. The operating contract.
    └── SCHEMA.md              ← Machine-readable schema for contracts, scorecards, ADRs.
```

Always read `_meta/SCHEMA.md` before writing a contract file or ADR. The schema is the source of truth for structure.

---

## Workflow: a typical session

**Session start:**

1. Read `.verification/MODE.md`. If unset, ask the human.
2. Read `.verification/CONFIG.md` for any per-mode overrides.
3. Read `.verification/_meta/SCHEMA.md` to refresh on file formats.
4. Glance at `.verification/INVARIANTS.md` and recent `contracts/` to load project context.

**When the human asks for design:**

1. Extract requirements. List them explicitly.
2. For each, propose a verification method and regression strategy.
3. Score each candidate contract using the scorecard.
4. Flag contracts that require human review per the escalation rule.
5. Write a verification plan. Present it. Wait for approval before designing.

**When the human asks for code:**

1. Identify the contracts this code creates or modifies.
2. Score them. If escalation triggers fire, ask for review.
3. Write the test first, then the code. Or write them together. Never write code without a corresponding test for any contract above `low` criticality.
4. Update or create the contract files in `.verification/contracts/`.
5. In the PR body, list: contracts touched, scorecards, tests added, coverage delta.

**When you finish a session:**

1. If session logging is enabled (check `.verification/sessions/` for prior logs), write a brief summary: what was decided, what contracts were added/modified, what's open.
2. If any contract scorecards changed, note it in the contract file's history section.

---

## Anti-patterns you must avoid

- **"I'll add tests later."** No. Tests are written with the code or before it. "Later" is the failure mode this entire methodology exists to prevent.
- **"This is too small to need a contract."** If the code touches state, it has a contract. Even if the contract is `low / low / low / pure / reversible`, write it down. The 30 seconds it costs is the cheapest insurance you'll ever buy.
- **"The human didn't ask about verification."** Irrelevant. Verification thinking is your default mode. The human hired this methodology by putting this file in the repo.
- **"I'll just declare the contract in the PR description."** No. Contracts live in `.verification/contracts/` as files. PR descriptions get lost. Files survive.
- **"This is a spike, so I'll skip the contracts file."** No. Spike mode relaxes test enforcement, not documentation. The whole point is that when the spike succeeds, you don't redo the thinking.
- **"I'll batch-update the scorecards at the end."** No. Scorecards update when contracts change. Drift is the enemy.
- **Confidently mis-scoping a contract.** This is the failure mode the confidence axis exists to catch. If you find yourself rationalizing a `high` confidence score on something you haven't seen before, downgrade to `med` or `low` and surface it for review.

---

## When you disagree with the human

Push back. The human chose this methodology because they want a collaborator with independent judgment, not a yes-machine. If you think a contract is mis-scored, say so. If you think the human's design has an untestable requirement they're glossing over, surface it. If you think the mode is wrong (e.g., they say "spike" but the code looks like infrastructure), ask.

Capitulate only when the human provides new evidence or a stronger argument. Restate your position if your reasoning still holds. Accuracy is the success metric, not approval.

---

## When this file is wrong

This file is itself versioned in git. If you find a case where the methodology produces a bad outcome, surface it. Propose an edit to this file as an ADR. The methodology improves the same way the codebase does: through ratcheted, reviewable changes.
