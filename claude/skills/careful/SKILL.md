---
name: careful
description: >
  Activate guardrails that block destructive operations for the rest of this session.
  Use when the user says /careful, "be careful", "I'm touching prod", "production mode",
  or before working on infrastructure, cluster configs, or deployment scripts.
allowed-tools: Read, Grep, Glob, Bash
user-invocable: true
hooks:
  - type: PreToolUse
    tool_name: Bash
    script: |
      BLOCKED_PATTERNS=(
        "rm -rf"
        "rm -fr"
        "git push --force"
        "git push -f"
        "git reset --hard"
        "git checkout -- ."
        "git clean -f"
        "DROP TABLE"
        "DROP DATABASE"
        "TRUNCATE"
        "kubectl delete"
        "docker system prune"
        "launchctl bootout"
        "pkill -9"
        "kill -9"
      )
      CMD=$(echo "$TOOL_INPUT" | jq -r '.command // empty')
      for pattern in "${BLOCKED_PATTERNS[@]}"; do
        if echo "$CMD" | grep -qi "$pattern"; then
          echo '{"decision": "block", "reason": "/careful mode: blocked destructive command: '"$pattern"'"}'
          exit 0
        fi
      done
      echo '{"decision": "allow"}'
metadata:
  author: SGridworks
  version: 1.0.0
  category: guardrails
  tags: [safety, production, destructive, guardrails]
---

# Careful Mode

Destructive operation guardrails are now active for this session.

## Blocked Operations

The following patterns are blocked in Bash commands:
- `rm -rf`, `rm -fr` -- recursive force delete
- `git push --force`, `git push -f` -- force push
- `git reset --hard` -- discard all changes
- `git checkout -- .`, `git clean -f` -- discard working tree
- `DROP TABLE`, `DROP DATABASE`, `TRUNCATE` -- destructive SQL
- `kubectl delete` -- Kubernetes resource deletion
- `docker system prune` -- Docker cleanup
- `launchctl bootout` -- stop LaunchAgents
- `pkill -9`, `kill -9` -- force kill processes

## How to Use

Invoke `/careful` before working on:
- Production infrastructure
- Cluster configs (Ollama, Hermes, LaunchAgents)
- Deployment scripts
- Database operations
- Any work where an accidental destructive command would be costly

The guardrails stay active for the entire session. To work without them, start a new session.

## Note

This does NOT block Edit/Write operations. For file-level protection, use `/freeze` instead.
