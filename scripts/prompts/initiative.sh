#!/usr/bin/env bash
# Appends the initiative task section to /tmp/agent-prompt.txt.
# Reads env vars: ISSUE_NUMBER, ISSUE_TITLE, REPO, ISSUE_BODY

set -euo pipefail

OUT=/tmp/agent-prompt.txt

cat >> "$OUT" << EOF

## Your task (initiative → proposal + epics)

Issue: #${ISSUE_NUMBER} — ${ISSUE_TITLE}

You are an architect agent. Do NOT write production code.

1. Read the initiative description and understand the goal
2. Brainstorm scope: what problem does this solve, what are the boundaries, what is explicitly out of scope
3. Propose an ordered list of epics that together deliver the initiative
4. For each epic:
   - Create a GitHub issue: \`gh issue create --title '<epic title>' --body '<epic description and acceptance criteria>' --label 'type:epic' --repo ${REPO}\`
   - Reference this initiative in the body
5. Post a comment on this initiative issue with:
   - Problem statement
   - Proposed approach
   - Ordered epic list (with links to created issues)
   - Out of scope items
   - Open questions (if any)
6. Label this initiative: \`gh issue edit ${ISSUE_NUMBER} --remove-label agent-coding --add-label agent-review --repo ${REPO}\`

Do not commit or push any code. Your deliverable is the epic issues and the proposal comment.

## Initiative Description

${ISSUE_BODY}
EOF
