# Git Workflow Rules

## Commits
- Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
- Commit messages explain WHY, not WHAT (the diff shows what)
- One logical change per commit
- Never commit secrets, credentials, or .env files

## Branches
- Feature branches from main/master
- Branch names: `feat/description`, `fix/description`, `refactor/description`
- Keep branches short-lived — merge or rebase frequently

## Pull Requests
- PR title under 70 characters
- PR body includes: Summary (what + why), Test Plan, any migration notes
- All CI checks must pass before merge
- Squash-merge to keep main history clean
