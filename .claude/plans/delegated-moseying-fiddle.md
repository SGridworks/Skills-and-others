# Plan: Replace Honcho with Obsidian LLM Wiki

## Context

Honcho served its purpose as an AI-native memory layer, but it's become a black box — observations trapped in SQLite, synced nightly via a brittle export, invisible unless you query it. The Karpathy LLM Wiki pattern offers something better: a persistent, human-browsable, LLM-maintained knowledge base in plain markdown. Obsidian gives us graph view, backlinks, search, and a real UI on top of it.

**Current state:**
- 42 Claude Code memory files (721 KB) in `~/.claude/projects/-Users-2agents/memory/`
- 149 active observations + 150 embeddings in `~/.hermes/honcho.db` (784 KB)
- 2 profiles (user + AI peer) with synthesized peer cards
- Honcho cloud API already disabled — fully local SQLite
- Hermes plugin interface: `MemoryProvider` ABC in `hermes-agent/agent/memory_provider.py`
- 8 existing memory providers, only 1 active at a time + built-in

**Target state:**
- `~/vault/` — single Obsidian vault, shared by Claude Code + Hermes
- Three layers: raw sources, wiki (LLM-maintained), schema (CLAUDE.md)
- Hermes `obsidian` memory plugin (new) as primary, honcho demoted to fallback
- Claude Code pointed at vault instead of `~/.claude/projects/-Users-2agents/memory/`
- No data loss — every Honcho observation and Claude memory migrated

---

## Phase 1: Export and Backup (no data loss guarantee)

### 1.1 Export Honcho SQLite to JSON
- Query `~/.hermes/honcho.db` for all observations, profiles, embeddings metadata
- Write to `~/vault/_migration/honcho_full_export.json`
- Include: id, content, target, category, confidence, created_at, active flag
- Skip raw embedding blobs (rebuild later with qmd if needed)

### 1.2 Snapshot Claude Code memory
- Copy `~/.claude/projects/-Users-2agents/memory/` to `~/vault/_migration/claude_memory_backup/`
- Preserve all frontmatter and content exactly

### 1.3 Snapshot Hermes identity files
- Copy `~/.hermes/honcho_identity.md`, `~/.hermes/honcho_export.json`

---

## Phase 2: Vault Structure

```
~/vault/
  .obsidian/              # Obsidian config (created on first open)
  CLAUDE.md               # Schema — wiki conventions, page formats, workflows
  index.md                # Master index of all wiki pages
  log.md                  # Chronological activity log

  raw-sources/            # Layer 1: immutable source documents
    articles/
    transcripts/
    exports/
    assets/               # Downloaded images

  wiki/                   # Layer 2: LLM-maintained knowledge
    me/                   # User profile, goals, preferences, personality
    projects/             # One page per active project
    people/               # Contacts, collaborators
    infrastructure/       # Cluster, services, config notes
    decisions/            # Decision log entries
    concepts/             # Domain knowledge pages
    summaries/            # Source summaries
    feedback/             # Behavioral guidance for AI agents

  memory/                 # Layer 2b: Agent memory (replaces ~/.claude/.../memory/)
    MEMORY.md             # Index (same format Claude Code expects)
    *.md                  # Individual memory files with frontmatter

  _migration/             # Phase 1 exports (delete after verification)
```

### 2.1 CLAUDE.md (Schema)
This is the critical file — it tells both Claude Code and Hermes how the vault works:
- Directory conventions
- Page format (YAML frontmatter: tags, created, updated, sources, links)
- Ingest workflow
- Query workflow
- Lint rules
- Naming conventions (kebab-case filenames, `[[wikilinks]]` for cross-refs)

### 2.2 index.md
- Auto-maintained catalog of every wiki page
- Grouped by category
- One line per page: `- [[page-name]] — one-line summary`
- LLM updates on every ingest/query that creates pages

### 2.3 log.md
- Append-only: `## [2026-04-12] ingest | Source Title`
- Parseable with grep

---

## Phase 3: Data Migration

### 3.1 Migrate Claude Code memory files → `~/vault/memory/`
- Move all 42 `.md` files, preserving frontmatter
- Update `MEMORY.md` index (same format, same line limit)
- Add Obsidian-compatible YAML properties (tags, aliases)

### 3.2 Migrate Honcho observations → wiki pages
- Parse `honcho_full_export.json`
- Group observations by category and target:
  - `user` + `fact` → merge into `wiki/me/profile.md`
  - `user` + `preference` → merge into `wiki/me/preferences.md`
  - `user` + `trait` → merge into `wiki/me/personality.md`
  - `user` + `correction` → merge into `wiki/feedback/` (one per correction, or grouped)
  - `ai` + `*` → merge into `wiki/infrastructure/hermes-identity.md`
- Deduplicate against existing Claude Code memory content (many overlap)
- Preserve timestamps as frontmatter `created:` field

### 3.3 Migrate Hermes identity
- `honcho_identity.md` → `wiki/me/peer-card.md`
- This becomes the canonical "who is Adam" page

### 3.4 Seed wiki/projects/ from existing project memory files
- Each `project-*.md` memory file becomes a wiki page in `wiki/projects/`
- Add backlinks between related projects
- Preserve all existing content

### 3.5 Build initial index.md
- Auto-generate from all migrated pages

---

## Phase 4: Hermes Obsidian Plugin

### 4.1 New plugin: `hermes-agent/plugins/memory/obsidian/`

**Files:**
- `__init__.py` — `ObsidianMemoryProvider(MemoryProvider)` 
- `vault.py` — Vault read/write/search operations
- `cli.py` — `hermes obsidian status`, `hermes obsidian lint`
- `plugin.yaml` — Metadata + description
- `README.md`

**Implements MemoryProvider ABC:**

| Method | Implementation |
|--------|---------------|
| `name` | `"obsidian"` |
| `is_available()` | Check `~/vault/` exists + `CLAUDE.md` present |
| `initialize()` | Read index.md, cache page catalog |
| `get_tool_schemas()` | 4 tools (see below) |
| `handle_tool_call()` | Route to vault operations |
| `system_prompt_block()` | Inject user profile from `wiki/me/peer-card.md` |
| `prefetch()` | FTS search over vault for relevant context |
| `sync_turn()` | Append to log.md, optionally update wiki pages |
| `on_session_end()` | Extract new observations, update wiki |
| `shutdown()` | Flush pending writes |

**Tool Schemas (4, matching Honcho's surface):**
1. `obsidian_profile` — Read `wiki/me/peer-card.md` (replaces `honcho_profile`)
2. `obsidian_search` — Full-text search across vault (replaces `honcho_search`)
3. `obsidian_read` — Read any wiki page by path or wikilink (replaces `honcho_context`)
4. `obsidian_write` — Create/update a wiki page + update index (replaces `honcho_conclude`)

**Search implementation:**
- Start with `grep -r` / ripgrep over markdown files (simple, no deps)
- Optional: integrate [qmd](https://github.com/tobi/qmd) later for hybrid BM25/vector search
- Read index.md first to narrow scope, then read matched pages

### 4.2 Config changes

**~/.hermes/config.yaml:**
```yaml
memory:
  provider: 'obsidian'    # was '' or 'honcho'

obsidian:
  vault_path: ~/vault
  auto_index: true         # Update index.md on writes
  auto_log: true           # Append to log.md on activity
  sync_to_claude: true     # Keep memory/ dir compatible with Claude Code
```

### 4.3 Honcho fallback
- Keep honcho plugin code intact
- Set `honcho.enabled: false` in config (already is)
- Can reactivate by changing `memory.provider: 'honcho'`

---

## Phase 5: Claude Code Integration

### 5.1 Update Claude Code memory path
- Claude Code's auto-memory currently targets `~/.claude/projects/-Users-2agents/memory/`
- The vault's `~/vault/memory/` directory mirrors this exact format (MEMORY.md index + frontmatter .md files)
- **Option A**: Symlink `~/.claude/projects/-Users-2agents/memory/` → `~/vault/memory/` (cleanest)
- **Option B**: Update CLAUDE.md instructions to point Claude Code at `~/vault/memory/`
- Recommend **Option A** — zero config change, Claude Code reads/writes to vault transparently

### 5.2 Update CLAUDE.md global instructions
- Add vault path reference: `~/vault/` is the canonical knowledge base
- Point to `~/vault/CLAUDE.md` for schema conventions
- Remove honcho-synced-facts.md references (no longer needed — data lives in vault)

### 5.3 Kill the nightly sync
- The honcho → claude sync cron job becomes unnecessary
- Both systems read/write the same vault directory
- Remove or disable the sync LaunchAgent

---

## Phase 6: Operations Setup

### 6.1 Ingest workflow
- Web Clipper → `~/vault/raw-sources/articles/`
- Manual drops (transcripts, PDFs, exports) → appropriate raw-sources subfolder
- Claude Code command to process new sources:
  ```
  claude -p "Process new files in ~/vault/raw-sources/. For each unprocessed file: read it, write a summary to wiki/summaries/, update index.md, update any related wiki pages, log the ingest." --allowedTools Bash,Write,Read
  ```

### 6.2 Lint workflow (weekly)
- Detect orphan pages, stale content, missing cross-references, contradictions
- Write report to `wiki/lint-report.md`

### 6.3 Morning briefing (optional, future)
- Cron job reads vault, surfaces open actions, new raw sources
- Can replace the honcho nightly sync with something more useful

---

## Phase 7: Verification

### 7.1 Data integrity
- [ ] Count: all 149 Honcho observations accounted for in wiki pages
- [ ] Count: all 42 Claude Code memory files present in `~/vault/memory/`
- [ ] Honcho peer card content matches `wiki/me/peer-card.md`
- [ ] No data in `_migration/` that isn't represented in the vault

### 7.2 Claude Code works
- [ ] Start new Claude Code session, verify it reads `~/vault/memory/MEMORY.md`
- [ ] Save a new memory, verify it appears in `~/vault/memory/`
- [ ] Open Obsidian, see the new file in real time

### 7.3 Hermes works
- [ ] `hermes obsidian status` shows vault connected
- [ ] Start Hermes conversation, verify profile injection from peer-card.md
- [ ] Use `obsidian_search` tool, verify results
- [ ] Use `obsidian_write` tool, verify page created + index updated
- [ ] Open Obsidian, see changes

### 7.4 Obsidian works
- [ ] Open vault in Obsidian
- [ ] Graph view shows interconnected pages
- [ ] Search works across all content
- [ ] Backlinks resolve correctly

---

## Critical Files

| File | Action |
|------|--------|
| `~/.hermes/honcho.db` | Export, then leave as fallback |
| `~/.claude/projects/-Users-2agents/memory/` | Symlink to `~/vault/memory/` |
| `~/.claude/CLAUDE.md` | Update vault references |
| `~/.hermes/config.yaml` | Change `memory.provider` to `obsidian` |
| `hermes-agent/plugins/memory/obsidian/__init__.py` | **NEW** — main plugin |
| `hermes-agent/plugins/memory/obsidian/vault.py` | **NEW** — vault operations |
| `hermes-agent/plugins/memory/obsidian/cli.py` | **NEW** — CLI commands |
| `hermes-agent/agent/memory_provider.py` | READ ONLY — reference for ABC |
| `~/vault/CLAUDE.md` | **NEW** — wiki schema |
| `~/vault/index.md` | **NEW** — master index |
| `~/vault/log.md` | **NEW** — activity log |

---

## Estimated Scope

- **Phase 1** (Export): 15 min — Python script to dump SQLite + copy files
- **Phase 2** (Structure): 10 min — mkdir + write schema files
- **Phase 3** (Migration): 30 min — Python script to transform and deduplicate
- **Phase 4** (Hermes plugin): 1-2 hours — the bulk of the work
- **Phase 5** (Claude Code): 10 min — symlink + CLAUDE.md update
- **Phase 6** (Operations): 20 min — write ingest/lint command templates
- **Phase 7** (Verification): 20 min — run through checklist

Total: ~3 hours of implementation, no data loss risk (backup first, migrate, verify, then cut over).
