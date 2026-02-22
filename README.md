# Skills-and-others

Claude Code skills, hooks, and configuration for SGridworks projects.

## Structure

```
.claude/
  hooks/
    session-start.sh   # SessionStart hook for Claude Code on the web
  settings.json        # Claude Code project settings
```

## Session Start Hook

The `session-start.sh` hook runs automatically when a Claude Code web session starts. It handles dependency installation and environment setup.

The hook only runs in remote (Claude Code on the web) environments and is skipped for local sessions.
