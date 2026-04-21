---
name: vault-ingest
description: "Ingest sources into the ~/vault/ wiki. Reads a source, extracts entities and concepts, creates or updates wiki pages, cross-references, and logs the operation. Supports files, URLs, images, and batch mode. Triggers on: ingest this, ingest this url, ingest this image, batch ingest, ingest all of these, add this to the vault, read and file this."
allowed-tools: Read Write Edit Glob Grep search_files terminal
---

# vault-ingest: Source Ingestion

Read the source. Write the wiki. Cross-reference everything. A single source typically touches 8-15 wiki pages.

**Syntax standard**: Obsidian Flavored Markdown. Wikilinks as `[[Note Name]]`, callouts as `> [!note]`, embeds as `![[file]]`, properties as YAML frontmatter.

---

## Folder Mapping

| Source folder | Target folder |
|---------------|---------------|
| wiki/sources/ | wiki/summaries/ |
| wiki/entities/ (people/orgs) | wiki/people/ |
| wiki/entities/ (products/repos) | wiki/projects/ |
| wiki/concepts/ | wiki/concepts/ |
| wiki/questions/ | wiki/summaries/ |
| wiki/domains/ | wiki/projects/ or wiki/infrastructure/ |
| wiki/meta/ | (skipped — lint reports go to wiki/ not a meta folder) |
| .raw/ | ~/vault/raw-sources/ (articles/, transcripts/, exports/, assets/) |
| wiki/log.md | ~/vault/log.md |
| wiki/index.md | ~/vault/index.md |

---

## Delta Tracking

Before ingesting any file, check `~/vault/.manifest.json` to avoid re-processing unchanged sources.

```bash
# Check if manifest exists
[ -f ~/vault/.manifest.json ] && echo "exists" || echo "no manifest yet"
```

**Manifest format** (create if missing):
```json
{
  "sources": {
    "raw-sources/articles/article-slug-2026-04-08.md": {
      "hash": "abc123",
      "ingested_at": "2026-04-08",
      "pages_created": ["wiki/summaries/article-slug.md", "wiki/people/Person.md"],
      "pages_updated": ["index.md"]
    }
  }
}
```

**Before ingesting a file:**
1. Compute a hash: `md5sum [file] | cut -d' ' -f1` (or `sha256sum` on Linux).
2. Check if the path exists in `~/vault/.manifest.json` with the same hash.
3. If hash matches, skip. Report: "Already ingested (unchanged). Use `force` to re-ingest."
4. If missing or hash differs, proceed with ingest.

**After ingesting a file:**
1. Record `{hash, ingested_at, pages_created, pages_updated}` in `~/vault/.manifest.json`.
2. Write the updated manifest back.

Skip delta checking if the user says "force ingest" or "re-ingest".

---

## URL Ingestion

Trigger: user passes a URL starting with `https://`.

Steps:

1. **Fetch** the page using WebFetch.
2. **Clean** (optional): if `defuddle` is available (`which defuddle`), run `defuddle parse [url]` to strip ads, nav, and clutter. Typically saves 40-60% tokens. Fall back to raw WebFetch output if not installed.
3. **Derive slug** from the URL path (last segment, lowercased, spaces→hyphens, strip query strings).
4. **Save** to `~/vault/raw-sources/articles/[slug]-[YYYY-MM-DD].md` with a frontmatter header:
   ```markdown
   ---
   source_url: [url]
   fetched: YYYY-MM-DD
   ---
   ```
5. Proceed with **Single Source Ingest** starting at step 2 (file is now in `raw-sources/`).

---

## Image / Vision Ingestion

Trigger: user passes an image file path (`.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`, `.svg`, `.avif`).

Steps:

1. **Read** the image file using the Read tool. Claude can process images natively.
2. **Describe** the image contents: extract all text (OCR), identify key concepts, entities, diagrams, and data visible in the image.
3. **Save** the description to `~/vault/raw-sources/articles/[slug]-[YYYY-MM-DD].md`:
   ```markdown
   ---
   source_type: image
   original_file: [original path]
   fetched: YYYY-MM-DD
   ---
   # Image: [slug]

   [Full description of image contents, transcribed text, entities visible, etc.]
   ```
4. Copy the image to `~/vault/raw-sources/assets/[slug].[ext]` if it's not already in the vault.
5. Proceed with **Single Source Ingest** on the saved description file.

Use cases: whiteboard photos, screenshots, diagrams, infographics, document scans.

---

## Single Source Ingest

Trigger: user drops a file into `raw-sources/` or pastes content.

Steps:

1. **Read** the source completely. Do not skim.
2. **Discuss** key takeaways with the user. Ask: "What should I emphasize? How granular?" Skip this if the user says "just ingest it."
3. **Create** source summary in `wiki/summaries/`. Use our frontmatter format:
   ```yaml
   ---
   title: "Source Title"
   tags: [tag1, tag2]
   created: YYYY-MM-DD
   updated: YYYY-MM-DD
   sources:
     - "[[raw-sources/articles/filename.md]]"
   ---
   ```
4. **Create or update** entity pages for every person, org, product, and repo mentioned:
   - People/Orgs → `wiki/people/`
   - Products/Repos → `wiki/projects/`
5. **Create or update** concept pages for significant ideas and frameworks → `wiki/concepts/`
6. **Update** relevant domain pages (`wiki/projects/` or `wiki/infrastructure/`) if they exist.
7. **Update** `~/vault/index.md`. Add entries for all new pages.
8. **Update** `~/vault/wiki/hot.md` with this ingest's context (see vault-hot-cache skill).
9. **Append** to `~/vault/log.md` (new entries at the TOP):
   ```markdown
   ## [YYYY-MM-DD] ingest | Source Title
   - Source: raw-sources/articles/filename.md
   - Summary: [[Source Title]]
   - Pages created: [[Page 1]], [[Page 2]]
   - Pages updated: [[Page 3]]
   - Key insight: One sentence on what is new.
   ```
10. **Check for contradictions.** If new info conflicts with existing pages, add blockquote callouts on both pages (see Contradictions section below).

---

## Batch Ingest

Trigger: user drops multiple files or says "ingest all of these."

Steps:

1. List all files to process. Confirm with user before starting.
2. Process each source following the single ingest flow. Defer cross-referencing between sources until step 3.
3. After all sources: do a cross-reference pass. Look for connections between the newly ingested sources.
4. Update index, hot cache, and log once at the end (not per-source).
5. Report: "Processed N sources. Created X pages, updated Y pages. Here are the key connections I found."

Batch ingest is less interactive. For 30+ sources, expect significant processing time. Check in with the user after every 10 sources.

---

## Context Window Discipline

Token budget matters. Follow these rules during ingest:

- Read `~/vault/wiki/hot.md` first. If it contains the relevant context, don't re-read full pages.
- Read `~/vault/index.md` to find existing pages before creating new ones.
- Read only 3-5 existing pages per ingest. If you need 10+, you are reading too broadly.
- Use PATCH for surgical edits. Never re-read an entire file just to update one field.
- Keep wiki pages short. 100-300 lines max. If a page grows beyond 300 lines, split it.
- Use search (`search_files`) to find specific content without reading full pages.

---

## Contradictions

When new info contradicts an existing wiki page, flag it with a blockquote. Do NOT use custom CSS callouts — use plain blockquotes instead:

On the existing page, add:
```markdown
> [!note] Contradiction with [[New Source]]
> [[Existing Page]] claims X. [[New Source]] says Y.
> Needs resolution. Check dates, context, and primary sources.
```

On the new source summary, reference it:
```markdown
> [!note] Contradicts [[Existing Page]]
> This source says Y, but existing wiki says X. See [[Existing Page]] for details.
```

Do not silently overwrite old claims. Flag and let the user decide.

---

## What Not to Do

- Do not modify anything in `~/vault/raw-sources/`. These are immutable source documents.
- Do not create duplicate pages. Always check `~/vault/index.md` and search before creating.
- Do not skip the log entry. Every ingest must be recorded.
- Do not skip the hot cache update. It is what keeps future sessions fast.
