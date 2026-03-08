# Build Fix Skill

## Purpose
Diagnose and resolve build, compilation, and dependency errors.

## When to Use
- When build/compile fails
- When tests fail due to infrastructure (not logic) issues
- When `/build-fix` command is invoked

## Methodology

1. **Capture Error Output** — Get the full error message and stack trace.
2. **Classify Error Type:**
   - **Dependency** — Missing package, version conflict, lock file mismatch
   - **Type/Syntax** — Type errors, syntax errors, import errors
   - **Configuration** — Wrong tsconfig, missing env vars, bad paths
   - **Runtime** — Port conflicts, permission issues, missing binaries
3. **Research** — Check the specific file and line referenced in the error.
4. **Fix** — Apply the minimal fix. Do NOT refactor surrounding code.
5. **Verify** — Re-run the failing command to confirm the fix works.
6. **Explain** — State what was wrong and why the fix works.

## Rules
- Fix the error, not symptoms — find root cause
- Minimal changes only — do not refactor
- Always verify the fix by re-running the failing command
- If a fix requires a breaking change, warn the user first
- Never delete lock files as a first resort — investigate why they're wrong
