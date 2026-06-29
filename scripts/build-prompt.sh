#!/usr/bin/env bash
# Dispatcher: builds $PROMPT_FILE by combining _common.sh + <ISSUE_TYPE>.sh
# Reads env vars: PROMPT_FILE, ISSUE_TYPE, ISSUE_NUMBER, ISSUE_TITLE, BRANCH,
#                 ISSUE_BODY, BUILD_CHECK, BUILD_TEST, CONVENTIONS, AGENT_EMAIL
# PROMPT_FILE (set by the workflow to a per-runner RUNNER_TEMP path) is inherited
# by the sourced sub-scripts; defaults to /tmp for local use.

# set -E so the ERR trap fires inside the sourced sub-scripts too.
set -Eeuo pipefail

# This step previously died with a bare "exit code 1" and no output, marking
# issues agent-failed before any agent ran. Make every failure say where it
# happened so it lands in the run log / issue comment.
trap 'rc=$?; printf "build-prompt.sh: FAILED (exit %s) at %s line %s -> %s\n" \
  "$rc" "${BASH_SOURCE[0]}" "${LINENO}" "${BASH_COMMAND}" >&2' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISSUE_TYPE="${ISSUE_TYPE:-story}"
PROMPT_FILE="${PROMPT_FILE:-/tmp/agent-prompt.txt}"
export PROMPT_FILE

TYPE_SCRIPT="$SCRIPT_DIR/prompts/${ISSUE_TYPE}.sh"
if [ ! -f "$TYPE_SCRIPT" ]; then
  echo "build-prompt.sh: unknown ISSUE_TYPE '$ISSUE_TYPE' — no $TYPE_SCRIPT" >&2
  exit 1
fi

# Source (not exec) the sub-scripts so the ERR trap above reports the failing
# file + line *inside* them rather than just "the build step died".
# shellcheck source=scripts/prompts/_common.sh
source "$SCRIPT_DIR/prompts/_common.sh"   # shared header (overwrites $PROMPT_FILE)
# shellcheck source=/dev/null
source "$TYPE_SCRIPT"                      # task section for this issue type

if [ ! -s "$PROMPT_FILE" ]; then
  echo "build-prompt.sh: produced an empty prompt at $PROMPT_FILE" >&2
  exit 1
fi

echo "build-prompt.sh: wrote $(wc -l < "$PROMPT_FILE") lines to $PROMPT_FILE (type: $ISSUE_TYPE)"
