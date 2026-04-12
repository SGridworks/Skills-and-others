# Notion Sync Skill

## Purpose
Sync project state between GitHub repos and the Notion Command Center.

## When to Use
- After completing a work session on any project
- When `/notion-sync` command is invoked
- When the user asks to update Notion

## Notion MCP Setup
The Notion MCP server is configured in `~/.claude.json` via `claude mcp add`.
Use `mcp__notion__*` tools to interact with Notion.

## Key IDs
- **Command Center page:** `3201f4ce-b9e3-8034-9029-f23a623824ab`
- **Projects database:** `3201f4ce-b9e3-8117-b5b3-e1427a9449b9`
- **Tasks database:** `3201f4ce-b9e3-8138-a916-e4dda0a096ab`
- **Notes & Ideas database:** `3201f4ce-b9e3-8165-969a-d1bc687c1bf1`

## Project Page IDs
- BTM Optimize: `3201f4ce-b9e3-818f-b8e2-e1b9e6ba5bac`
- td-aip: `3201f4ce-b9e3-811f-8724-e5cd75fbabf1`
- AgentGuard: `3201f4ce-b9e3-81cc-9cce-d2fce8a9650c`
- AgentGuard Scanner: `3201f4ce-b9e3-81f7-956c-d73334a06df1`
- AgentGuard Dashboard: `3201f4ce-b9e3-815a-9cbe-fa2386a1f053`
- SP&L: `3201f4ce-b9e3-8118-84eb-cbe0d0ba91d3`
- Dynamic-Network-Model: `3201f4ce-b9e3-8140-aaaa-e6f58d77ce57`
- fercoff: `3201f4ce-b9e3-8133-bc83-ee8a0b6e9677`
- olivetree-mcp: `3201f4ce-b9e3-8181-9d86-fa13fdf87a09`
- patristic-mcp: `3201f4ce-b9e3-81e8-b3d6-cdb747a7e5f3`
- bible-api-mcp: `3201f4ce-b9e3-8196-80c5-fdf48f36f9b7`
- SGridworks Website: `3201f4ce-b9e3-81e5-a54f-ff2bb443e091`
- Opportunity Scout: `3201f4ce-b9e3-81e0-b01b-e5394d06dd26`
- Voice Extractor: `3201f4ce-b9e3-810b-818f-feb0963da774`

## Domain Taxonomy
- **Energy:** BTM Optimize, td-aip, SP&L, Dynamic-Network-Model, fercoff
- **Security:** AgentGuard, AgentGuard Scanner, AgentGuard Dashboard, Secure LLM White Paper
- **Theology:** olivetree-mcp, patristic-mcp, bible-api-mcp
- **Infrastructure:** Thunderbolt AI, Kimi Swarm, Voice Extractor, Morning Briefing
- **Consulting:** Noteworthy AI, Opportunity Scout, SGridworks Website

## Status Values
- `Active` - Currently being worked on
- `Shipped` - Code complete, deployed or published
- `Planning` - Designed but not started
- `Paused` - Deprioritized, revisit later
- `Archived` - Dead or superseded

## Sync Procedure

### Step 1: Gather git state
```bash
# Get recent commits
git log --oneline -5 --format="%h %s (%ar)"
# Count tests (Python projects)
find . -name "test_*.py" -o -name "*_test.py" | xargs grep -c "def test_" 2>/dev/null | awk -F: '{s+=$2} END {print s" tests"}'
# Get current branch
git branch --show-current
```

### Step 2: Look up the project page ID
Match the repo name or cwd to the Project Page IDs table above.

### Step 3: Update the project page
Use `mcp__notion__API-patch-page` with this structure:

```json
{
  "page_id": "<project-page-id>",
  "properties": {
    "Notes": {
      "rich_text": [{"text": {"content": "<state summary from git log>"}}]
    },
    "Status": {
      "select": {"name": "Active"}
    },
    "Last Activity": {
      "date": {"start": "2026-03-24"}
    }
  }
}
```

**Property types in the Projects database:**
- `Name` -- title (don't update, it's the project name)
- `Status` -- select: Active | Shipped | Planning | Paused | Archived
- `Notes` -- rich_text (free-form state summary)
- `Last Activity` -- date (ISO format, date only)
- `Domain` -- select: Energy | Security | Theology | Infrastructure | Consulting
- `Project` -- relation (only in Tasks database, links to Projects)

**If a property doesn't exist** (API returns 400 with "property not found"), remove
that property from the payload and retry. Don't fail the whole sync.

### Step 4: Create tasks (if needed)
Use `mcp__notion__API-post-page`:

```json
{
  "parent": {"database_id": "3201f4ce-b9e3-8138-a916-e4dda0a096ab"},
  "properties": {
    "Name": {
      "title": [{"text": {"content": "<task description>"}}]
    },
    "Status": {
      "select": {"name": "Not Started"}
    },
    "Project": {
      "relation": [{"id": "<project-page-id>"}]
    }
  }
}
```

Task status values: `Not Started` | `In Progress` | `Done` | `Blocked`

### Step 5: Confirm
After syncing, output:
```
NOTION SYNC COMPLETE
  Project:      <name>
  Page:         <page-id>
  Status:       <old> -> <new> (or unchanged)
  Notes:        <first 80 chars of summary>...
  Last Activity: <date>
  Tasks created: <N>
  Tasks updated: <N>
```
