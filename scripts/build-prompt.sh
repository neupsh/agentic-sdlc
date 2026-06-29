#!/usr/bin/env bash
# Dispatcher: builds $PROMPT_FILE by combining _common.sh + <ISSUE_TYPE>.sh
# Reads env vars: PROMPT_FILE, ISSUE_TYPE, ISSUE_NUMBER, ISSUE_TITLE, BRANCH,
#                 ISSUE_BODY, BUILD_CHECK, BUILD_TEST, CONVENTIONS, AGENT_EMAIL
# PROMPT_FILE (set by the workflow to a per-runner RUNNER_TEMP path) is inherited
# by the child scripts via the environment; defaults to /tmp for local use.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISSUE_TYPE="${ISSUE_TYPE:-story}"

# Write shared header (overwrites $PROMPT_FILE)
bash "$SCRIPT_DIR/prompts/_common.sh"

# Append task section for this issue type
bash "$SCRIPT_DIR/prompts/${ISSUE_TYPE}.sh"
