# ADR 0002: Add install.sh as primary adoption path

**Status:** accepted
**Date:** 2026-05-12
**Deciders:** matteomelani
**Supersedes:** n/a
**Superseded by:** n/a

## Context

The existing adoption path requires manually running several `cp` commands (documented in `README.md`). This is friction-heavy, error-prone (easy to miss a file), and not the kind of experience that encourages adoption of a framework whose whole pitch is "this makes things easier." The template needs a single command that correctly installs all required files, prompts for mode, and cleans up after itself.

There are two distinct invocation contexts to support: users who discover the template and want zero-friction installation (`curl | bash`), and users who want to audit the script first and run it locally (`./install.sh /path/to/project`).

## Decision

Add `install.sh` to the repository root. It is the primary adoption path. The README is updated to present it first, with `cp -r` instructions preserved as a fallback.

## Rationale

A single script eliminates the "which files do I need to copy?" question and the "I forgot `.github/copilot-instructions.md`" failure mode. The mode prompt surfaces a decision that users must make but the README currently buries in step 2. The `curl | bash` path matches the convention users already know from tools like Homebrew and nvm.

Alternatives considered below.

## Alternatives considered

- **GitHub template repository:** Users click "Use this template" and get all files. Rejected because it only works for new projects; existing projects are the primary use case.
- **npm/pip/brew package:** Rejected as unnecessary infrastructure for what is a simple file-copy operation. Adds a distribution dependency that complicates updates.
- **Keep cp -r only:** Rejected because it's too easy to miss files and there's no mode prompt.

## Consequences

### Positive
- Single-command adoption for new users
- Mode selection is prompted explicitly rather than buried in docs
- Example files are cleaned up automatically
- `curl | bash` path means no clone required for most users

### Negative
- Script must be kept in sync with the set of files it installs; adding a new root-level tool-pointer file requires updating `install.sh`
- `curl | bash` requires users to trust the script; security-conscious users will use the manual clone path

### Neutral
- `cp -r` instructions remain in README as fallback; no existing documentation is removed

## Verification impact

- Contracts created: contracts/0002-install-safety-gate.md, contracts/0003-install-file-copy-completeness.md, contracts/0004-install-example-deletion-precision.md, contracts/0005-install-mode-prompt.md, contracts/0006-install-curl-bash-temp-cleanup.md, contracts/0007-readme-install-documentation.md
- Contracts modified: n/a
- Contracts deprecated: n/a
