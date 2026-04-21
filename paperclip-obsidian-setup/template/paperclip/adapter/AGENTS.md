# Hermes Paperclip Adapter — Development Guide

## Overview

This is a Paperclip adapter that runs Hermes Agent as a managed employee.
It implements the `ServerAdapterModule` interface from `@paperclipai/adapter-utils`.

## Structure

```
src/
├── index.ts              # Root: type, label, models, agentConfigurationDoc
├── shared/constants.ts   # Shared constants (regex, defaults)
├── server/
│   ├── index.ts          # Re-exports execute + testEnvironment
│   ├── execute.ts        # Core execution (spawn hermes CLI)
│   └── test.ts           # Environment checks (CLI, Python, API keys)
├── ui/
│   ├── index.ts          # Re-exports
│   ├── parse-stdout.ts   # Hermes stdout → TranscriptEntry[]
│   └── build-config.ts   # UI form → adapterConfig
└── cli/
    ├── index.ts          # Re-exports
    └── format-event.ts   # Terminal output formatting
```

## Key Interfaces

The adapter implements `ServerAdapterModule`:
- `execute(ctx)` — spawns `hermes chat -q "..."`, returns `AdapterExecutionResult`
- `testEnvironment(ctx)` — checks CLI, Python, API keys
- `models` — list of available LLM models
- `agentConfigurationDoc` — markdown docs for the config form

## Build

```bash
npm install
npm run build     # tsc → dist/
npm run typecheck # type checking only
```

## Testing against a local Paperclip instance

1. Build this adapter: `npm run build`
2. In your Paperclip repo, add this as a local dependency
3. Register in `server/src/adapters/registry.ts`
4. Create an agent with `adapterType: "hermes_local"`
5. Trigger a heartbeat and observe logs

## Adapter Config Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `model` | string | `MiniMax-M2.7-highspeed` | Model for this agent |
| `provider` | string | `auto` | Inference provider |
| `cwd` | string | `.` | Working directory (use absolute path) |
| `hermesCommand` | string | `hermes` | Path to hermes CLI |
| `timeoutSec` | number | `300` | Execution timeout |
| `graceSec` | number | `30` | Grace period after timeout |
| `maxTurnsPerRun` | number | `120` | Max conversation turns |
| `promptTemplate` | string | (see execute.ts) | Custom prompt template |
| `persistSession` | boolean | `true` | Keep session across heartbeats |
| `checkpoints` | boolean | `false` | Enable filesystem checkpoints |
| `paperclipApiUrl` | string | `http://127.0.0.1:3100/api` | Paperclip API base URL |

## Hermes CLI Flags (Verified)

```
-q/--query         single query (non-interactive)
-Q/--quiet         quiet mode (no banner/spinner, only response + session_id)
-m/--model         model name (e.g. minimax/MiniMax-M2.7-highspeed)
-t/--toolsets      comma-separated toolsets to enable
--provider         inference provider (auto, minimax, openai, etc.)
-r/--resume        resume session by ID
-w/--worktree      isolated git worktree
-v/--verbose       verbose output
--checkpoints      filesystem checkpoints
```
