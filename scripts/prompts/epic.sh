#!/usr/bin/env bash
# Appends the epic task section to $PROMPT_FILE.
# Reads env vars: PROMPT_FILE, ISSUE_NUMBER, ISSUE_TITLE, REPO, ISSUE_BODY

set -euo pipefail

OUT="${PROMPT_FILE:-/tmp/agent-prompt.txt}"

cat >> "$OUT" << EOF

## Your task (epic → spec + stories)

Issue: #${ISSUE_NUMBER} — ${ISSUE_TITLE}

You are an architect agent. Do NOT write production code.

1. Read the epic description thoroughly
2. Write a detailed spec covering:
   - Data models (fields, types, constraints)
   - Function/trait signatures and port boundaries
   - API contracts (request/response shapes)
   - Error types and edge cases to handle
   - Test scenarios (unit + integration + E2E)
3. Break the epic into ordered stories. For each story:
   - Create a GitHub issue: \`gh issue create --title '<story title>' --body '<spec excerpt for this story>' --label 'type:story,agent-ready' --repo ${REPO}\`
   - Keep each story independently implementable
4. Post a summary comment on this epic issue listing the created story issues
5. Label this epic: \`gh issue edit ${ISSUE_NUMBER} --remove-label agent-coding --add-label agent-review --repo ${REPO}\`

Do not commit or push any code. Your deliverable is the story issues and the summary comment.

## Epic Description

${ISSUE_BODY}
EOF
