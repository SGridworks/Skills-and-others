# Guardrails Rules

## Recommend, Never Act

Skills and workflows should follow the "recommend, never act" pattern for destructive or irreversible operations:

### NEVER (without explicit user approval)
- Delete files, branches, or data
- Merge, close, or modify PRs or issues
- Send messages, emails, or notifications
- Pay, authorize, or schedule payments
- Cancel, pause, or modify subscriptions
- Push code to remote repositories
- Modify shared infrastructure or permissions

### ALWAYS
- Present options and let the user decide
- Show what will happen before doing it
- Flag items as "needs review" when uncertain
- Provide an undo path when possible
- End reports with a summary count line

## Output Standards

### Priority Tiers
Use consistent priority levels across all skills:
- **Critical/Urgent (red)** -- requires immediate action, blocking
- **High/Important (yellow)** -- needs attention today
- **Medium/FYI (green)** -- informational, no rush
- **Low/Skip (gray)** -- can be ignored or deferred

### Summary Lines
Every skill output should end with a scannable one-line summary:
- Code review: "X critical, X high, X medium, X low"
- Verification: "X passed, X failed, X skipped"
- CI check: "X blocked, X need action, X waiting, X ready"
- Planning: "X phases, X files, estimated X sessions"

### Tables Over Paragraphs
Prefer tables for structured data. Keep text to summaries and observations.

## Data Safety

### Read-Only by Default
Skills should be read-only unless their explicit purpose requires writing:
- Code review: read-only
- Verification: read + execute tests (no file modifications)
- Planning: read-only
- Build-fix: read + write (explicit purpose is fixing code)

### Sensitive Data
- NEVER extract or display full credentials, API keys, or tokens
- Only store last 4 digits of account numbers
- NEVER log sensitive data to pattern files or artifacts
- Flag potential secrets for the user to review
