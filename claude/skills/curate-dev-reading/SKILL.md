---
name: curate-dev-reading
description: >
  Surface high-quality technical articles from Hacker News, Reddit, and dev blogs
  filtered by the user's tech stack and interests. Use when user says "what should
  I read", "dev reading list", "any good tech articles", or "what's new in tech".
  Do NOT auto-subscribe to any service.
allowed-tools: Read, Grep, Glob, Bash, WebSearch, WebFetch
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: productivity
  tags: [reading, news, articles, learning]
---

# Curate Dev Reading Skill

5 great technical articles instead of 30 mediocre ones.

## Instructions

### Step 1: Detect Tech Stack
Read the project's package.json, go.mod, Cargo.toml, pyproject.toml, or similar to identify the user's tech stack. Use this to filter articles.

### Step 2: Check Interest Preferences
If user hasn't specified interests, default to topics related to their detected stack plus: software architecture, developer tooling, and engineering practices.

### Step 3: Fetch Articles
- **Hacker News** -- top stories via API, filter for relevance
- **Reddit** -- relevant programming subreddits
- **Dev blogs** -- search for recent posts on stack-specific topics

### Step 4: Filter
Remove:
- Paywalled content
- Clickbait and listicles (unless genuinely useful)
- Purely promotional content
- Duplicates

### Step 5: Select and Rank
Choose 5-10 articles that are:
- Substantive -- teaches something or enables action
- Relevant to the user's stack and interests
- Recent (prefer last 7 days)

Rank by: relevance, source quality, recency.

### Step 6: Summarize
For each article:
- Title and source
- Direct link
- Estimated reading time
- 2-3 sentence summary and why it's worth reading

## Output Format

### Dev Reading List -- [Date]

1. **[Title]** -- [Source]
   [Link] | ~X min read
   [2-3 sentence summary]

2. **[Title]** -- [Source]
   [Link] | ~X min read
   [2-3 sentence summary]

[...up to 10]

**Stack detected:** [languages/frameworks found in project]

## Rules
- Quality over quantity -- 5 great articles beats 15 mediocre ones
- NEVER auto-subscribe to any newsletter or service
- Skip purely promotional content
- If fewer than 5 articles meet the quality bar, deliver fewer
- Rotate sources -- don't pull everything from one place
- If a source is down, skip it and note the issue
- Prioritize practical content (tutorials, case studies, post-mortems) over opinion pieces
