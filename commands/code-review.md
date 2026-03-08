---
name: code-review
description: Run a structured code review on recent changes
arguments: scope (optional — file path, branch, or "staged")
---

Use the Code Review skill to review code changes.

Scope: $ARGUMENTS

If no scope specified, review all uncommitted changes (staged + unstaged).

Rank all findings by severity: Critical > High > Medium > Low. Never approve code with Critical findings. Always check for hardcoded secrets.
