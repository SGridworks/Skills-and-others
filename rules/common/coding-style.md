# Coding Style Rules

## Universal
- Functions should do one thing and be under 50 lines
- Prefer immutability — create new objects rather than mutating
- Use descriptive names — no single-letter variables except loop counters
- No commented-out code — delete it (git has history)
- No TODO comments without a linked issue
- Keep files under 400 lines; split if larger
- Prefer early returns over deep nesting
- No magic numbers — use named constants

## Formatting
- Use the project's configured formatter (Prettier, Black, gofmt, etc.)
- Consistent indentation (follow existing codebase)
- No trailing whitespace
- Files end with a single newline
