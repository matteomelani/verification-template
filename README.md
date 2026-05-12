# verification-template

A template repo for **verification-first engineering** with AI coding agents.

The premise: tests, contracts, and eval baselines are *design inputs*, not design outputs. They are how you decide what to write, not artifacts you add later. With AI coding agents removing the effort wall to comprehensive verification, this approach is no longer expensive — but it requires a framework. This template is that framework.

## What's in this repo

- **`.verification/`** — the methodology folder. Lives in your project's git repo. Contains the operating contract, contract files, ADRs, eval baselines, and session logs.
- **`CLAUDE.md`** — points Claude Code at the operating contract.
- **`AGENTS.md`** — points generic AI agents at the operating contract.
- **`.cursorrules`** — points Cursor at the operating contract.
- **`.github/copilot-instructions.md`** — points GitHub Copilot at the operating contract.

All the tool-pointer files at the root say the same thing: *read `.verification/_meta/PROMPT.md`*. That keeps the methodology in one place and lets any tool participate.

## How to use this template

### To start a new project

1. Clone or copy this repo into your new project directory:
   ```bash
   cp -r verification-template/.verification path/to/your/project/
   cp verification-template/CLAUDE.md verification-template/AGENTS.md verification-template/.cursorrules path/to/your/project/
   mkdir -p path/to/your/project/.github
   cp verification-template/.github/copilot-instructions.md path/to/your/project/.github/
   ```
2. Edit `.verification/MODE.md` to set the project mode (`spike`, `product`, or `infrastructure`).
3. Delete the example files (`contracts/0001-example-*.md`, `decisions/0001-example-*.md`) — they exist only to demonstrate the schema.
4. Commit. Your project is now under verification-first methodology.

### To use this template on an existing project

Same as above, but be aware: applying this methodology to an existing codebase means the LLM will surface a lot of unstated contracts. That's good — it's a forcing function for documenting institutional knowledge — but it takes time. Consider starting in `spike` mode and promoting to `product` once the contract list stabilizes.

### To evolve the methodology

The methodology is itself versioned in `.verification/`. If you find a case where it produces bad outcomes, propose an edit to `_meta/PROMPT.md` or `_meta/SCHEMA.md`, document the change as an ADR, and improve the template by upstreaming your fix.

## The three modes

The verification rigor required depends on the project's mode, set in `.verification/MODE.md`:

| Mode | Use for | Tests | Coverage | Evals | Dialogue |
|---|---|---|---|---|---|
| **spike** | Exploratory, likely throwaway | Required only for high-criticality / irreversible contracts | None | Optional | Asks before irreversible actions |
| **product** | Maintained code, real product | Required for med+ criticality | 80%+, never drops | Required for non-deterministic surfaces | Asks per escalation rule |
| **infrastructure** | Foundational, others depend on it | Required for all contracts | 90%+, never drops | Required + versioned baselines | Asks for all contract changes; ADRs required |

In every mode, the LLM still tracks contracts and scorecards. The mode controls *enforcement*, not *documentation*. This way, promoting a spike to product mode doesn't require redoing the verification work.

## The contract scorecard

Every contract (behavioral invariant) is scored on five axes:

- **Criticality** (low / med / high) — how bad is a violation?
- **LLM confidence** (low / med / high) — how sure is the LLM that it has correctly identified the contract?
- **Parallelization value** (low / med / high) — does locking this contract down enable independent work streams?
- **Surface type** (state-mutating / pure / presentation)
- **Reversibility** (reversible / irreversible)

Scoring triggers human review when any of these are true:
- Criticality is `high`
- Reversibility is `irreversible`
- LLM confidence is `low`
- Surface type is `state-mutating` AND criticality is `med` or `high`

Everything else: the LLM declares the scorecard, writes the contract file, and proceeds. Humans can review and override at any time — the scorecards live in git.

## Why this works

The methodology rests on three observations:

1. **AI coding agents removed the effort wall to comprehensive testing.** Writing thorough tests used to require sustained human willpower; now it's free. The old "tests later" tradeoff no longer applies.
2. **Tests and contracts as institutional memory survive personnel turnover.** Senior engineers leave; `.verification/contracts/0001-name.md` doesn't.
3. **Asking the LLM to articulate contracts forces it to slow down.** The number on the scorecard is less important than the act of producing it. An LLM that writes the scorecard before the code is an LLM that has thought about what it is doing.

This methodology was inspired by Garry Tan's [Agent Complexity Ratchet](https://garrytan.com) post and by DO-178C / Six Sigma reliability-engineering traditions, but it differs from both by making verification a *design input* and adding human-in-the-loop triage via scorecards.

## License

MIT.
