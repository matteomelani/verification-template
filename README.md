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

### Option 1 — curl | bash (recommended)

Run this in your project's root directory:

```bash
curl -fsSL https://raw.githubusercontent.com/matteomelani/verification-template/main/install.sh | bash
```

The script will:
- Check that the directory exists, is writable, and is inside a git repo
- Prompt before overwriting any existing `.verification/` folder
- Copy all required files into your project
- Delete the example contract and ADR (they exist only to demonstrate the schema)
- Prompt you to choose a mode (`spike`, `product`, or `infrastructure`)
- Print what was installed and what to do next

### Option 2 — manual clone

Clone the repo locally, inspect the script, then run it:

```bash
git clone https://github.com/matteomelani/verification-template.git
./verification-template/install.sh /path/to/your/project
```

### Option 3 — manual copy (fallback)

If you prefer not to run a script:

```bash
cp -r verification-template/.verification path/to/your/project/
cp verification-template/CLAUDE.md verification-template/AGENTS.md verification-template/.cursorrules path/to/your/project/
mkdir -p path/to/your/project/.github
cp verification-template/.github/copilot-instructions.md path/to/your/project/.github/
```

Then manually edit `.verification/MODE.md` to set the project mode, and delete the example files (`contracts/0001-example-*.md`, `decisions/0001-example-*.md`).

---

After any installation method, commit the added files:

```bash
git add .verification CLAUDE.md AGENTS.md .cursorrules .github/copilot-instructions.md
git commit -m "add verification-first framework"
```

Your project is now under verification-first methodology.

### Applying to an existing project

Applying this methodology to an existing codebase means the LLM will surface a lot of unstated contracts. That's good — it's a forcing function for documenting institutional knowledge — but it takes time. Consider starting in `spike` mode and promoting to `product` once the contract list stabilizes.

### To evolve the methodology

The methodology is itself versioned in `.verification/`. If you find a case where it produces bad outcomes, propose an edit to `_meta/PROMPT.md` or `_meta/SCHEMA.md`, document the change as an ADR, and improve the template by upstreaming your fix.

## Example workflow

This is the day-to-day loop once the framework is installed. The example is a
single feature, but the same loop applies to any unit of work.

Say the next task is "add a CSV export to the reports page."

1. **Rationalize the task.** Read it against the existing code, design, and
   data before writing anything. Ask: does it duplicate an existing pattern,
   conflict with current behavior, or touch anything risky? Write the answer
   down. This step decides what the contracts should be.

2. **Write the invariants as contracts.** Create one or more
   `contracts/NNNN-slug.md` files. Reuse standing contracts where they apply
   (for example, an existing "all exports stream, never buffer in memory"
   contract). Add a feature-specific contract for anything new (for example,
   "the CSV export must match the on-screen report row for row").

3. **Score each contract and choose how it is checked.** Fill in the
   scorecard. In `Verification.Method`, mark each contract as a deterministic
   check (`unit`, `integration`, `property`) or a judged one (`eval`). Prefer
   deterministic checks; reserve `eval` for genuinely semantic guarantees.
   If a rule is system-wide rather than feature-specific, promote it to
   `INVARIANTS.md` and link the contract.

4. **Build with the contracts in context.** The agent (Cursor, Claude Code,
   Codex) reads `.verification/` through the pointer files, so the contracts
   act as design inputs and prevent violations up front.

5. **Verify the pull request against the contracts.** Run the tests and evals
   the contracts name. Any contract whose scorecard triggers an escalation
   (high criticality, irreversible, low LLM confidence, or a state-mutating
   medium+ surface) requires human review before merge.

6. **Merge only when the contracts pass.** If a check fails, it loops back to
   the builder. Log any deliberate shortcut as production debt with its real
   fix, so nothing silent reaches production.

In one line: rationalize the task, write its invariants as contracts, sort each
into a machine check or an LLM judgment, build with the contracts in context,
then verify the pull request against those same contracts before merge.

## How much can the agent do?

The agent can help with every step of the workflow, and that is the point.
Comprehensive verification is only affordable because agents removed the effort
wall to writing it. The rule that keeps this honest: the check must stay
independent of the build. If a single agent rationalizes the task, writes the
contracts, builds the feature, and then verifies it in one unbroken pass, the
grader and the student are the same. Keep them separate, and keep a human at the
high-stakes gates.

Where the agent helps at each step:

1. **Rationalize.** Strong use. The agent reads the existing code, design, and
   data and surfaces conflicts, duplicate patterns, and risks. It only reasons
   over what is in its context, and it sounds equally confident when guessing,
   so you sanity-check what it flagged and what it may have missed. This is what
   the `LLM confidence` scorecard axis is for.
2. **Write the contracts.** The agent drafts the contract files and proposes the
   scorecard. Ratify `criticality` yourself, because criticality encodes
   business stakes the model does not own.
3. **Score and write the checks.** The agent proposes the deterministic-versus-
   `eval` split and can write the lint rules, property tests, and eval rubrics.
   Watch tests that judge the agent's own code: an agent can write a weak test
   that passes trivially. General deterministic rules resist this; output-
   specific tests get a human read.
4. **Build.** The builder. Putting the contracts in context makes it produce
   more compliant code up front.
5. **Verify.** The danger zone. An agent judging an agent's output, especially
   the same model, shares blind spots and leans toward passing. Deterministic
   checks are trustworthy because they pass or fail mechanically with no model
   opinion at check time. For checks that genuinely need an `eval`, use a
   different model as the judge or add a human spot-check. The escalation rules
   force a human in at the high-stakes points.
6. **Merge and log debt.** The agent can draft the production-debt entry, but
   the merge on a protected `main` and the review of escalated contracts stay
   human.

Three guardrails make full agent help safe rather than circular:

- **You ratify criticality and escalation calls.** They carry business stakes
  the model does not have.
- **Prefer deterministic checks over judged ones.** A machine test is an
  independent arbiter; a model judging its own work is not. When you must judge
  with a model, use a different one or a human spot-check.
- **Keep a human at the merge gate** for high-criticality, irreversible, and
  state-mutating contracts.

One practical move makes the whole loop safe to hand off: **separate the roles
into different sessions.** Use one agent to rationalize and write the contracts,
a second to build, and a third to verify against the contracts. Even with the
same underlying model, the verifier is not anchored on the builder's reasoning,
which blunts the self-grading problem. The framework already points this way,
because the contract is written before and independently of the build, and
verification is defined by the contract rather than by whoever wrote the code.

The throughline: the more of your checks you push into the deterministic bucket,
the more of this loop you can hand to the agent with confidence, because the
final word belongs to a machine test instead of the model's opinion of its own
work.

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
