---
name: build-fix
description: >
  Diagnose and resolve build, compilation, and dependency errors by finding root
  causes and applying minimal fixes. Use when user says "build failed", "fix this
  error", "compilation error", "dependency issue", "npm install failed", "type error",
  "import not found", or pastes an error message from a build/compile/test failure.
  Do NOT use for logic bugs (use code-review), test failures due to wrong assertions
  (fix the logic), or general refactoring.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
model: inherit
user-invocable: true
arguments: error message (optional)
compatibility: Requires project with a build system or compiler.
license: MIT
metadata:
  author: SGridworks
  version: 2.0.0
  category: workflow
  tags: [build, errors, debugging, dependencies, compilation]
---

# Build Fix Skill

Error context: $ARGUMENTS

If no error provided, run the build command, capture the error, and fix it.

## Instructions

### Step 1: Capture Error Output
Get the full error message and stack trace. If the user didn't provide one, run the build/compile command to reproduce it.

### Step 2: Classify Error Type
- **Dependency** -- Missing package, version conflict, lock file mismatch
- **Type/Syntax** -- Type errors, syntax errors, import errors
- **Configuration** -- Wrong tsconfig, missing env vars, bad paths
- **Runtime** -- Port conflicts, permission issues, missing binaries

### Step 3: Research
Read the specific file and line referenced in the error. Check surrounding code for context.

### Step 4: Fix
Apply the minimal fix. Do NOT refactor surrounding code. Change only what is necessary.

### Step 5: Verify
Re-run the failing command to confirm the fix works. If it fails with a different error, go back to Step 1.

### Step 6: Explain
State what was wrong and why the fix works.

## Examples

Example 1: Missing dependency
User says: "npm run build is failing"
Actions:
1. Run `npm run build`, capture error: "Cannot find module 'zod'"
2. Classify: Dependency error -- missing package
3. Fix: Run `npm install zod`
4. Verify: Re-run `npm run build` -- success
Result: Dependency installed, build passes

Example 2: Type error
User pastes: "error TS2345: Argument of type 'string' is not assignable to parameter of type 'number'"
Actions:
1. Read the file and line from the error
2. Classify: Type error -- wrong argument type
3. Research: Check the function signature and the caller
4. Fix: Parse the string to number with `parseInt()` or fix the type
5. Verify: Run `npx tsc --noEmit` -- clean
Result: Type error fixed, explains the mismatch

## Troubleshooting

Error: Fix causes a new error
Cause: The original fix was addressing a symptom, not root cause
Solution: Step back, trace the dependency chain, find the actual root cause

Error: Lock file conflicts
Cause: Lock file out of sync with package.json
Solution: Do NOT delete the lock file. Run the package manager's resolution command (e.g., `npm install`, `go mod tidy`)

## Rules
- Fix the error, not symptoms -- find root cause
- Minimal changes only -- do not refactor
- Always verify the fix by re-running the failing command
- If a fix requires a breaking change, warn the user first
- Never delete lock files as a first resort -- investigate why they're wrong
