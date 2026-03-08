---
name: build-fix
description: Diagnose and fix build/compile errors
arguments: error message (optional)
---

Use the Build Fix skill.

Error context: $ARGUMENTS

If no error provided, run the build command, capture the error, and fix it. Always verify the fix by re-running the failing command.
