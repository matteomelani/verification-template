#!/usr/bin/env bash
# install.sh — apply the verification-first framework to an existing project.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/matteomelani/verification-template/main/install.sh | bash
#   ./install.sh /path/to/project
#
# Environment variable overrides (for non-interactive / scripted use):
#   INSTALL_MODE=spike|product|infrastructure   — skip the mode prompt
#   INSTALL_OVERWRITE=yes                        — skip the overwrite confirmation

set -euo pipefail

REPO_URL="https://github.com/matteomelani/verification-template.git"

# ── Cleanup trap (contract 0006) ──────────────────────────────────────────────
# _TMPDIR is initialized before trap so `set -u` never sees it unset.
_TMPDIR=""
_cleanup() {
    if [[ -n "$_TMPDIR" && -d "$_TMPDIR" ]]; then
        rm -rf "$_TMPDIR"
    fi
}
trap _cleanup EXIT

# ── Determine source directory ────────────────────────────────────────────────
# If this script is running from a local clone of the template repo, use that
# directory as the source. Otherwise (curl | bash), we must clone.
_NEEDS_CLONE=true
SOURCE=""

# BASH_SOURCE[0] is empty or "bash" when piped from curl; it's a real path
# when the script is executed directly.
if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != "bash" ]]; then
    _script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"
    if [[ -d "${_script_dir}/.verification" ]]; then
        SOURCE="$_script_dir"
        _NEEDS_CLONE=false
    fi
fi

# ── Determine target directory ────────────────────────────────────────────────
if [[ $# -ge 1 ]]; then
    TARGET="$1"
else
    TARGET="$(pwd)"
fi

# ── Safety checks (contract 0002) ────────────────────────────────────────────

# 1. Target exists
if [[ ! -d "$TARGET" ]]; then
    echo "Error: target directory does not exist: $TARGET" >&2
    exit 1
fi

# Normalize to absolute path before any further checks
TARGET="$(cd "$TARGET" && pwd)"

# 2. Target is writable
if [[ ! -w "$TARGET" ]]; then
    echo "Error: target directory is not writable: $TARGET" >&2
    exit 1
fi

# 3. Target is inside a git repository
if ! git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: '$TARGET' is not inside a git repository." >&2
    echo "       Initialize one first:  git -C '$TARGET' init" >&2
    exit 1
fi

# 4. Prompt before overwriting an existing .verification/ (contract 0002c)
if [[ -d "$TARGET/.verification" ]]; then
    if [[ "${INSTALL_OVERWRITE:-}" == "yes" ]]; then
        echo "Note: overwriting existing '$TARGET/.verification/' (INSTALL_OVERWRITE=yes)."
    else
        echo "Warning: '$TARGET/.verification' already exists." >&2
        _confirm=""
        # Read from /dev/tty so this works even when stdin is the script pipe
        read -rp "Overwrite it? [y/N] " _confirm </dev/tty || {
            echo "Error: no terminal available for confirmation. Set INSTALL_OVERWRITE=yes to skip." >&2
            exit 1
        }
        case "${_confirm:-}" in
            [yY]|[yY][eE][sS]) ;;
            *)
                echo "Aborted." >&2
                exit 1
                ;;
        esac
    fi
fi

# ── Clone if needed (contract 0006) ──────────────────────────────────────────
if [[ "$_NEEDS_CLONE" == true ]]; then
    echo "Cloning verification-template..."
    # _TMPDIR is set after trap registration — cleanup is guaranteed.
    _TMPDIR="$(mktemp -d)"
    git clone --quiet --depth=1 "$REPO_URL" "$_TMPDIR/repo"
    SOURCE="$_TMPDIR/repo"
fi

# ── Copy files (contract 0003) ────────────────────────────────────────────────
echo "Installing verification framework to: $TARGET"

# .verification/ — remove stale copy first so deleted upstream files don't linger
rm -rf "$TARGET/.verification"
cp -r "$SOURCE/.verification" "$TARGET/.verification"

# Root-level tool-pointer files
cp "$SOURCE/CLAUDE.md"    "$TARGET/CLAUDE.md"
cp "$SOURCE/AGENTS.md"    "$TARGET/AGENTS.md"
cp "$SOURCE/.cursorrules" "$TARGET/.cursorrules"

# .github/copilot-instructions.md — create .github/ if absent
mkdir -p "$TARGET/.github"
cp "$SOURCE/.github/copilot-instructions.md" "$TARGET/.github/copilot-instructions.md"

# ── Delete example files (contract 0004) ─────────────────────────────────────
rm -f "$TARGET/.verification/contracts/0001-example-settlement-idempotency.md"
rm -f "$TARGET/.verification/decisions/0001-example-adopt-verification-first.md"

# ── Prompt for mode (contract 0005) ──────────────────────────────────────────
echo ""
echo "Select project mode:"
echo "  spike          — exploratory, likely throwaway"
echo "  product        — maintained code, real product"
echo "  infrastructure — foundational, others depend on it"
echo ""

if [[ -n "${INSTALL_MODE:-}" ]]; then
    case "$INSTALL_MODE" in
        spike|product|infrastructure)
            _mode="$INSTALL_MODE"
            echo "Mode set from INSTALL_MODE env var: $_mode"
            ;;
        *)
            echo "Error: INSTALL_MODE='$INSTALL_MODE' is not valid. Use spike, product, or infrastructure." >&2
            exit 1
            ;;
    esac
else
    _mode=""
    while true; do
        read -rp "Mode [spike/product/infrastructure]: " _mode </dev/tty || {
            echo "Error: no terminal available for mode selection. Set INSTALL_MODE=spike|product|infrastructure." >&2
            exit 1
        }
        case "$_mode" in
            spike|product|infrastructure) break ;;
            *) echo "  Invalid. Please enter spike, product, or infrastructure." ;;
        esac
    done
fi

# Write MODE.md preserving the comment block from the template
printf '%s\n\n# Valid values: spike | product | infrastructure\n#\n# Change this line when the project'"'"'s mode changes. The LLM reads this file at\n# the start of every session. When promoting modes (spike -> product ->\n# infrastructure), re-review all contract scorecards.\n#\n# See .verification/_meta/PROMPT.md for what each mode means.\n' \
    "$_mode" > "$TARGET/.verification/MODE.md"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "Installed successfully."
echo ""
echo "  Files:"
echo "    .verification/                      (methodology folder)"
echo "    CLAUDE.md                           (Claude Code pointer)"
echo "    AGENTS.md                           (generic agent pointer)"
echo "    .cursorrules                        (Cursor pointer)"
echo "    .github/copilot-instructions.md     (GitHub Copilot pointer)"
echo ""
echo "  Mode: $_mode"
echo ""
echo "  Next steps:"
echo "    1. Commit: git -C '$TARGET' add .verification CLAUDE.md AGENTS.md .cursorrules .github/copilot-instructions.md"
echo "       then:   git -C '$TARGET' commit -m 'add verification-first framework'"
echo "    2. Read .verification/README.md to understand the methodology."
echo "    3. Start a session — your AI agent reads .verification/_meta/PROMPT.md automatically."
