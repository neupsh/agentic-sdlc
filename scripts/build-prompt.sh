#!/usr/bin/env bash
# Dispatcher: builds /tmp/agent-prompt.txt by combining _common.sh + <ISSUE_TYPE>.sh
# Reads env vars: ISSUE_TYPE, ISSUE_NUMBER, ISSUE_TITLE, BRANCH, ISSUE_BODY,
#                 BUILD_CHECK, BUILD_TEST, CONVENTIONS, AGENT_EMAIL

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISSUE_TYPE="${ISSUE_TYPE:-story}"

# Write shared header (overwrites /tmp/agent-prompt.txt)
bash "$SCRIPT_DIR/prompts/_common.sh"

# Append task section for this issue type
bash "$SCRIPT_DIR/prompts/${ISSUE_TYPE}.sh"
