# `.verification/` — what this folder is

This folder contains the verification artifacts for this project: contracts, decisions, eval baselines, and the operating contract that LLMs and dev tools follow.

It exists because of one simple idea: **verification is a design input, not a design output.** Tests aren't something you add after writing code. They're how you decide what to write.

## Why this exists

In traditional software development, tests trail behind code. You write the code, then if you have time, you write tests. If you don't have time, you ship and hope. This produces codebases where the test suite is patchy, regressions go undetected, and institutional knowledge lives only in the heads of senior engineers.

AI coding agents change the economics: the effort wall that stopped human teams from reaching high coverage has collapsed. Writing comprehensive tests no longer requires sustained human willpower. But the agent only writes the right tests if it has the right framework. This folder is that framework.

The methodology is:

1. **Before designing**, the LLM extracts requirements and asks how each will be verified. Untestable requirements are flagged as design risk.
2. **Before coding**, the LLM names the contracts (behavioral invariants) it is creating or modifying, scores them on a rubric, and asks for human review on high-stakes ones.
3. **Every contract** is recorded as a file in `contracts/`. Tests are written with the code, not after.
4. **Every non-obvious decision** is recorded as an ADR in `decisions/`. Future humans and LLMs can read why.
5. **Every non-deterministic surface** (LLM calls, ranking, fuzzy matching) has a baseline in `evals/`. New versions are scored against the baseline.

## The mode

The project's mode is declared in `MODE.md`. It's one of:

- **`spike`** — exploratory code, likely throwaway. The methodology still applies but enforcement is relaxed.
- **`product`** — code that will be maintained. Standard enforcement.
- **`infrastructure`** — foundational code that others depend on. Strict enforcement.

Modes can be promoted (spike → product → infrastructure) as the project matures. When you promote, re-review all contract scorecards.

## How to use this folder as a human

You don't need to read every file. The LLM does that. Your role is:

1. **Review escalated contracts.** When the LLM scores a contract as `high` criticality or `low` confidence (or any of the other escalation triggers), it will ask you to review the scorecard before proceeding. Read `contracts/NNNN-name.md`, accept or override the scoring, and the LLM will adjust the verification plan accordingly.
2. **Review ADRs.** When the LLM proposes an ADR in `decisions/`, read it. ADRs are the institutional memory of *why* — they're worth your attention.
3. **Audit when needed.** When something goes wrong (a bug, an incident, a regression), the contract and ADR history is your audit trail. The scorecard told you what the LLM thought was important; if it missed something, fix the scorecard and the methodology improves.
4. **Update the mode.** When the project's stakes change, update `MODE.md`. The LLM picks it up on the next session.

## How to use this folder as an LLM or agent

Start every session by reading `_meta/PROMPT.md`. That is the operating contract. Then read `MODE.md` and `_meta/SCHEMA.md`. Then proceed.

This folder is designed to be tool-agnostic. Cursor, Claude Code, Codex, Copilot, and any future agent should all read from and write to this folder using the same schema. The schema is enforced by `_meta/SCHEMA.md`, not by any particular tool.

## Folder layout

```
.verification/
├── README.md          ← This file. Human entry point.
├── MODE.md            ← Project mode: spike | product | infrastructure
├── CONFIG.md          ← Per-mode overrides (optional)
├── INVARIANTS.md      ← Project-level invariants. The "must never" list.
├── contracts/         ← One file per contract. Numbered: 0001-name.md
├── decisions/         ← Architecture Decision Records (ADRs)
├── evals/             ← One folder per non-deterministic surface
├── sessions/          ← Optional: rolling log of session summaries
└── _meta/
    ├── PROMPT.md      ← The operating contract that LLMs follow
    └── SCHEMA.md      ← File format reference. Read before writing.
```

## A note on what this is not

This is not a test framework. It does not run tests. It does not enforce coverage. Those jobs belong to your existing CI, test runner, and coverage tool.

What this is: a structured way to make the LLM *think about verification first*, record what it thinks, and let you correct it when it's wrong. The tests themselves live in your normal `tests/` directory and run via your normal CI. This folder is the layer above that — the layer that decides *what* gets tested and *why*.

## Evolving this methodology

If you find the methodology produces a bad outcome on your project, fix it. Add an ADR explaining the change, update `_meta/PROMPT.md` or `_meta/SCHEMA.md`, and the LLM will pick up the new rules on the next session.

The methodology improves the same way the codebase does: through ratcheted, reviewable changes.
