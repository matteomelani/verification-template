# CLAUDE.md — operating contract pointer

This project uses a verification-first engineering methodology. Before doing any substantive work, read:

**`.verification/_meta/PROMPT.md`**

That file is the operating contract. It explains how to handle design requests, code requests, contract scoring, mode-aware enforcement, and the dialogue protocol for human review.

After reading it, also check:

- **`.verification/MODE.md`** — the current project mode (spike | product | infrastructure)
- **`.verification/_meta/SCHEMA.md`** — file format reference for contracts, ADRs, and evals
- **`.verification/INVARIANTS.md`** — the project's "must never" list (skim it)

The `.verification/` folder is the source of truth for verification methodology in this project. Every other tool's config (`.cursorrules`, `AGENTS.md`, etc.) points to the same place. Edit the methodology by editing files in `.verification/`, not by editing tool-specific configs.
