# Theologian — Reformed Theological Research Agent

A Claude Code skill that transforms Claude into a Reformed theological research agent backed by 4 MCP servers, 2M+ database records, and primary source access spanning Scripture, patristics, confessions, and classic Reformed works.

## What It Does

When activated via `/theologian`, Claude operates as a research agent with:

- **Reformed theological identity** — Grounded in Calvin, Bavinck, Sproul, MacArthur
- **Postmillennial eschatology** with charitable engagement of other positions
- **Source hierarchy** — Scripture > Creeds > Confessions > Fathers > Theologians > Modern scholarship
- **Real-time database queries** across 4 specialized MCP servers
- **Academic rigor** — Steel-mans opposing views, flags genuine debates, cites primary sources

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  Claude Code                     │
│              /theologian skill                   │
│         (SKILL.md + SOUL.md identity)           │
└──────────┬──────────┬──────────┬───────────┬────┘
           │          │          │           │
     ┌─────▼──┐  ┌───▼────┐ ┌──▼─────┐ ┌───▼────┐
     │TheologAI│  │Bible API│ │Patristic│ │OliveTree│
     │12 tools │  │5 tools  │ │7 tools  │ │8 tools  │
     └────┬────┘  └───┬────┘ └───┬────┘ └────┬───┘
          │           │          │            │
    ┌─────▼─────┐   bolls   ┌───▼─────┐   Olive
    │theologai.db│  .life   │patristic │   Tree
    │abbott-smith│  API     │  .db     │   local
    │ macula.db  │          │writings  │   DB
    │ loci.json  │          │  .db     │
    └────────────┘          └──────────┘
```

## Data at a Glance

| Server | Records | Content |
|--------|---------|---------|
| TheologAI | 1.4M+ | Bible text, 344k cross-refs, 14k Strong's, 447k morphology, 6 commentaries, 49 confessions, 1000+ CCEL works, Abbott-Smith lexicon, Macula syntax trees |
| Bible API | Remote | NASB/ESV/NKJV/KJV/Greek/Hebrew via bolls.life, BDB/Thayer's dictionaries |
| Patristic | 73k+ | 63,706 verse-indexed commentaries (318 fathers), 765 full works in 10,013 sections (341 authors, ANF/NPNF) |
| Olive Tree | Local | 80 owned resources — metadata, navigation, annotations (text is DRM-protected) |

## Quick Start

### 1. Install the Skill

Copy the skill files into your Claude Code configuration:

```bash
# From this repo
cp -r skills/theologian ~/.claude/skills/theologian
```

Or add the skill reference to your project's `.claude/settings.json`.

### 2. Set Up MCP Servers

Each MCP server needs to be cloned, built, and registered. See [MCP Server Setup](#mcp-server-setup) below.

### 3. Activate

In any Claude Code session:

```
/theologian
```

Claude will acknowledge the role switch and ask what you're working on.

## MCP Server Setup

### TheologAI (primary research server)

The core theological database server. Fork of [TJ-Frederick/TheologAI](https://github.com/TJ-Frederick/TheologAI) with extended data.

```bash
cd ~/Projects
git clone https://github.com/TJ-Frederick/TheologAI.git
cd TheologAI
npm install
npm run build
```

**Databases** (place in `data/` directory):
- `theologai.db` — Bible text, cross-references, Strong's, morphology, commentaries, confessions, CCEL works
- `abbott-smith.db` — 5,896 Greek lexicon entries (FTS5 full-text search)
- `macula.db` — 1,065,506 syntax tree records from [Clear-Bible/macula-hebrew](https://github.com/Clear-Bible/macula-hebrew) and [macula-greek](https://github.com/Clear-Bible/macula-greek)
- `theological-loci.json` — Routing table mapping 8 systematic theology loci to sources

**Tools (12):** `bible_lookup`, `bible_cross_references`, `bible_verse_morphology`, `original_language_lookup`, `commentary_lookup`, `classic_text_lookup`, `parallel_passages`, `macula_syntax`, `theological_loci`, `olive_tree_lookup`, `donation_config`, `verify_donation`

### Bible API (translation access)

Lightweight MCP server wrapping [bolls.life](https://bolls.life) for multi-translation Bible access.

```bash
cd ~/Projects
git clone https://github.com/SGridworks/bible-api-mcp.git
cd bible-api-mcp
npm install
npm run build
```

No database needed — queries bolls.life API directly.

**Tools (5):** `bible_passage` (default NASB), `bible_search`, `bible_parallel`, `bible_dictionary`, `bible_books`

### Patristic (church fathers)

Verse-indexed patristic commentaries and full treatise texts from ANF/NPNF collections.

```bash
cd ~/Projects
git clone https://github.com/SGridworks/patristic-mcp.git
cd patristic-mcp
npm install
npm run build
```

**Databases** (built via ingestion scripts from open-source datasets):
- `patristic.db` — 63,706 verse-indexed commentaries from [HistoricalChristianFaith/Commentaries-Database](https://github.com/HistoricalChristianFaith/Commentaries-Database) (119 MB)
- `writings.db` — 765 full works from [HistoricalChristianFaith/Writings-Database](https://github.com/HistoricalChristianFaith/Writings-Database) (230 MB)

```bash
# Build databases from source data
npm run ingest          # patristic.db
npm run ingest-writings # writings.db
```

**Tools (7):** `patristic_by_verse`, `patristic_by_author`, `patristic_search`, `patristic_list_authors`, `patristic_writings_search`, `patristic_writings_by_author`, `patristic_writings_read`

### Olive Tree (optional — personal library)

Accesses metadata and annotations from Olive Tree Bible Reader. Only useful if you own Olive Tree resources on macOS.

```bash
cd ~/Projects
git clone https://github.com/SGridworks/olivetree-mcp.git
cd olivetree-mcp
npm install
npm run build
```

Reads from: `~/Library/Group Containers/group.com.olivetree.BibleReaderMac/Documents/`

**Tools (8):** `olivetree_list_resources`, `olivetree_browse_toc`, `olivetree_get_annotations`, `olivetree_export_annotations`, `olivetree_deep_link`, `olivetree_cross_references`, `olivetree_verse_navigation`, `olivetree_dictionary_lookup`

## Claude Code Configuration

Register all servers in your user-level settings (`~/.claude/settings.json`):

```json
{
  "mcpServers": {
    "theologai": {
      "command": "node",
      "args": ["dist/index.js"],
      "cwd": "~/Projects/TheologAI",
      "env": { "PORT": "" }
    },
    "bible-api": {
      "command": "node",
      "args": ["dist/index.js"],
      "cwd": "~/Projects/bible-api-mcp"
    },
    "patristic": {
      "command": "node",
      "args": ["dist/server.js"],
      "cwd": "~/Projects/patristic-mcp"
    },
    "olivetree": {
      "command": "node",
      "args": ["dist/index.js"],
      "cwd": "~/Projects/olivetree-mcp"
    }
  }
}
```

A complete example config is in `mcp-configs/claude-settings-example.json`.

## Minimal Setup (2 servers)

If you want the core experience without the full stack:

1. **TheologAI** — Bible text, morphology, commentaries, confessions, CCEL (covers 80% of use cases)
2. **Bible API** — Multi-translation access and dictionary lookups

The patristic and Olive Tree servers add depth but are not required.

## Data Sources

All data is sourced from open, freely available datasets:

| Dataset | Source | License |
|---------|--------|---------|
| Bible text + morphology | TheologAI base (TJ-Frederick) | MIT |
| Cross-references | TheologAI | MIT |
| Confessions/Creeds | [NonlinearFruit/Creeds.json](https://github.com/NonlinearFruit/Creeds.json) | Public domain |
| Abbott-Smith Lexicon | TEI XML (public domain, 1922) | Public domain |
| Macula Hebrew/Greek | [Clear-Bible](https://github.com/Clear-Bible) | CC BY 4.0 |
| CCEL Classic Works | [Christian Classics Ethereal Library](https://www.ccel.org) | Public domain |
| Patristic Commentaries | [HistoricalChristianFaith](https://github.com/HistoricalChristianFaith/Commentaries-Database) | Public domain (ANF/NPNF) |
| Patristic Writings | [HistoricalChristianFaith](https://github.com/HistoricalChristianFaith/Writings-Database) | Public domain (ANF/NPNF) |
| Bible translations | [bolls.life](https://bolls.life) | Fair use (API) |

## Translation Preferences

| Priority | Translation | Access |
|----------|-------------|--------|
| 1 | LSB (Legacy Standard Bible) | No API available |
| 2 | NASB (functional default) | bolls.life |
| 3 | ESV | bolls.life + TheologAI |
| 4 | NKJV | bolls.life |
| 5 | KJV | Everywhere |

## Example Queries

Once `/theologian` is active:

- "Exegete Romans 9:19-23 with attention to the Greek and Reformed commentators"
- "Compare supralapsarian and infralapsarian positions with Scripture support"
- "What did Augustine, Chrysostom, and Calvin say about John 6:44?"
- "Trace the doctrine of federal headship from Romans 5 through the Westminster Standards"
- "Analyze the Hebrew syntax of Genesis 1:1-3 using Macula data"

## File Structure

```
skills/theologian/
├── README.md              # This file
├── SKILL.md               # Skill definition (frontmatter + activation prompt)
├── SOUL.md                # Reformed theological identity and methodology
└── mcp-configs/
    ├── theologai.json     # TheologAI server config
    ├── bible-api.json     # Bible API server config
    ├── patristic.json     # Patristic server config
    ├── olivetree.json     # Olive Tree server config (optional)
    └── claude-settings-example.json  # Complete settings.json example
```

## Contributing

Questions, issues, or suggestions: [open an issue](https://github.com/SGridworks/Skills-and-others/issues)

Contributions welcome for:
- Additional confession/creed data
- Commentary source integrations
- Translation API adapters
- Tool improvements
