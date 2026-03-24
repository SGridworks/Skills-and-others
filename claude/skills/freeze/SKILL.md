---
name: freeze
description: >
  Lock all file modifications except in a specific directory. Use when the user
  says /freeze, "only edit files in X", "don't touch anything outside", or when
  debugging where you want to add logs but not accidentally modify unrelated code.
  Provide the allowed directory as an argument: /freeze src/btm_optimize/modules/
allowed-tools: Read, Grep, Glob, Bash
user-invocable: true
arguments: allowed_directory (required)
hooks:
  - type: PreToolUse
    tool_name: Edit
    script: |
      ALLOWED_DIR="$ARGUMENTS"
      if [ -z "$ALLOWED_DIR" ]; then
        echo '{"decision": "allow"}'
        exit 0
      fi
      FILE=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')
      if echo "$FILE" | grep -q "$ALLOWED_DIR"; then
        echo '{"decision": "allow"}'
      else
        echo '{"decision": "block", "reason": "/freeze mode: edits restricted to '"$ALLOWED_DIR"'. Blocked: '"$FILE"'"}'
      fi
  - type: PreToolUse
    tool_name: Write
    script: |
      ALLOWED_DIR="$ARGUMENTS"
      if [ -z "$ALLOWED_DIR" ]; then
        echo '{"decision": "allow"}'
        exit 0
      fi
      FILE=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty')
      if echo "$FILE" | grep -q "$ALLOWED_DIR"; then
        echo '{"decision": "allow"}'
      else
        echo '{"decision": "block", "reason": "/freeze mode: writes restricted to '"$ALLOWED_DIR"'. Blocked: '"$FILE"'"}'
      fi
metadata:
  author: SGridworks
  version: 1.0.0
  category: guardrails
  tags: [safety, freeze, file-protection, debugging]
---

# Freeze Mode

File modifications are now restricted to: **$ARGUMENTS**

Any Edit or Write operation targeting files outside this directory will be blocked.

## Usage

```
/freeze demo_data/          # only allow edits in demo_data/
/freeze src/btm_optimize/   # only allow edits in btm_optimize source
/freeze notebooks/          # only allow edits in notebooks
```

## When to Use

- Debugging: you want to add log statements but not accidentally "fix" unrelated code
- Focused refactoring: constrain changes to one module
- Code review fixes: only touch the files under review

## Note

Read, Grep, Glob, and Bash are not restricted -- you can still explore the full codebase. Only Edit and Write are blocked outside the allowed directory.

To remove the restriction, start a new session.
