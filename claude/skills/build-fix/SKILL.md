---
name: build-fix
description: Diagnose and fix build/compile/dependency errors
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
model: inherit
user-invocable: true
arguments: error message (optional)
---

# Build Fix Skill

Error context: $ARGUMENTS

If no error provided, run the build command, capture the error, and fix it. Always verify the fix by re-running the failing command.

## Methodology

1. **Capture Error Output** -- Get the full error message and stack trace.
2. **Classify Error Type:**
   - **Dependency** -- Missing package, version conflict, lock file mismatch
   - **Type/Syntax** -- Type errors, syntax errors, import errors
   - **Configuration** -- Wrong tsconfig, missing env vars, bad paths
   - **Runtime** -- Port conflicts, permission issues, missing binaries
3. **Research** -- Check the specific file and line referenced in the error.
4. **Fix** -- Apply the minimal fix. Do NOT refactor surrounding code.
5. **Verify** -- Re-run the failing command to confirm the fix works.
6. **Explain** -- State what was wrong and why the fix works.

## Rules
- Fix the error, not symptoms -- find root cause
- Minimal changes only -- do not refactor
- Always verify the fix by re-running the failing command
- If a fix requires a breaking change, warn the user first
- Never delete lock files as a first resort -- investigate why they're wrong
