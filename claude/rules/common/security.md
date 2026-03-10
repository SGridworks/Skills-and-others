# Security Rules

## Secrets
- NEVER hardcode secrets, API keys, passwords, or tokens
- Use environment variables or secret managers
- Never log secrets or include them in error messages
- Add secret patterns to .gitignore

## Input Validation
- Validate all user input at system boundaries
- Use parameterized queries — never interpolate user input into SQL
- Sanitize output to prevent XSS
- Validate and sanitize file paths to prevent path traversal

## Authentication & Authorization
- Never store passwords in plaintext — use bcrypt/argon2
- Validate JWT tokens on every request
- Check authorization for every protected resource
- Use HTTPS for all external communication

## Dependencies
- Keep dependencies updated
- Audit for known vulnerabilities (`npm audit`, `pip audit`, `govulncheck`)
- Pin dependency versions in lock files
- Review new dependency additions for trust signals
