# OpenClaw Configuration

OpenClaw agent definitions, skills, and configs for the 14-agent system.

## Structure

```
openclaw/
  skills/                         # OpenClaw-specific workflows
    check-subscriptions/SKILL.md  # Find forgotten recurring charges
    check-bills/SKILL.md          # Never miss a payment
    track-budget/SKILL.md         # Weekly spending visibility
    plan-week/SKILL.md            # Sunday evening week planning
    check-calendar/SKILL.md       # 48-hour calendar lookahead
    clean-email/SKILL.md          # Inbox clutter cleanup
    check-messages/SKILL.md       # Cross-platform message summary
    review-week/SKILL.md          # Friday weekly retrospective
    track-packages/SKILL.md       # Consolidated package tracking
    curate-reading/SKILL.md       # Daily curated reading list
  agents/                         # Agent definitions (future)
  configs/                        # Configuration templates (future)
```

## Skills Overview

All skills follow the same pattern:
- Pull data from things you already have (email, calendar, messages)
- Organize messy information into something clear and actionable
- Run on a schedule so you never have to remember
- Recommend actions but NEVER take action without your approval

### Personal Finance
| Skill | Schedule | What It Does |
|-------|----------|-------------|
| check-subscriptions | 1st of month | Scans for forgotten recurring charges |
| check-bills | Monday 8am | Flags upcoming and overdue bills |
| track-budget | Friday 6pm | Weekly spending snapshot by category |

### Productivity
| Skill | Schedule | What It Does |
|-------|----------|-------------|
| plan-week | Sunday 6pm | Weekly planning from calendar data |
| check-calendar | Daily 8am + 6pm | 48-hour lookahead with prep actions |
| clean-email | 1st of month | Inbox clutter identification |
| check-messages | 4x daily | Cross-platform message prioritization |
| review-week | Friday 5pm | Weekly accomplishment summary |

### Personal
| Skill | Schedule | What It Does |
|-------|----------|-------------|
| track-packages | Daily 8am + 5pm | Consolidated shipment tracking |
| curate-reading | Daily 8am | Curated article recommendations |

## Installation

1. Copy a skill's `SKILL.md` to `~/.openclaw/skills/<name>/SKILL.md`
2. The workflow runs on its schedule, or trigger on demand by messaging your agent

## Frontmatter Format

OpenClaw skills use the same YAML frontmatter as Claude Code skills, plus a `schedule` field:

```yaml
---
name: skill-name
description: What it does and when to trigger it
schedule: "monday 8am"          # OpenClaw-specific: cron-like schedule
allowed-tools: gws-gmail        # Tools the skill can use
model: sonnet
---
```

## Relationship to Claude Code

- **OpenClaw skills** (`openclaw/`) -- personal productivity workflows using email, calendar, and messaging platforms
- **Claude Code skills** (`claude/`) -- developer workflows using git, CI, and code tools

Claude Code content lives in the `claude/` directory. See the root README for the full architecture.
