#!/usr/bin/env bash
# Configures a prepare-commit-msg hook so EVERY agent commit in this job records the
# model + reasoning effort that produced it, as commit trailers (provenance). This is
# deterministic — it doesn't rely on the agent remembering to add them.
#
# Run from the caller's git checkout root. Reads env: AGENT_MODEL, AGENT_EFFORT,
# RUNNER_TEMP. Sets core.hooksPath (shared across this checkout's worktrees).

set -euo pipefail

HOOKS="${RUNNER_TEMP:-/tmp}/githooks"
mkdir -p "$HOOKS"

# Baked trailer content (read by the hook at commit time).
printf 'Agent-Model: %s\nAgent-Effort: %s\n' \
  "${AGENT_MODEL:-unknown}" "${AGENT_EFFORT:-unknown}" > "$HOOKS/agent-trailer.txt"

# The hook appends the trailer once (skips if already present, e.g. on amend).
{
  echo '#!/bin/sh'
  echo "T=\"$HOOKS/agent-trailer.txt\""
  echo 'grep -q "^Agent-Model:" "$1" 2>/dev/null && exit 0'
  echo '[ -f "$T" ] && { printf "\n" >> "$1"; cat "$T" >> "$1"; }'
} > "$HOOKS/prepare-commit-msg"
chmod +x "$HOOKS/prepare-commit-msg"

git config core.hooksPath "$HOOKS"
echo "commit-trailers: Agent-Model=${AGENT_MODEL:-unknown} Agent-Effort=${AGENT_EFFORT:-unknown}"
