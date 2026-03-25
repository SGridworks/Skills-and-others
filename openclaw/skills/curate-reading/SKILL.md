---
name: curate-reading
description: >
  Surface 5-10 high-quality articles from Hacker News, Reddit, RSS feeds, and
  newsletters filtered by interest preferences. Use when user says "what should
  I read", "reading list", "any good articles", or every morning at 8am.
  Do NOT auto-subscribe to any newsletter or service.
schedule: "daily 8am"
allowed-tools: web-fetch, web-search, gws-gmail
model: sonnet
user-invocable: true
license: MIT
metadata:
  author: SGridworks
  version: 1.0.0
  category: productivity
  tags: [reading, news, curation, articles]
---

# Curate Reading List Skill

5 great articles instead of 30 mediocre ones.

## Instructions

### Step 1: Check Interests
If user hasn't set interest preferences, ask for 3-5 topics to track. Defaults: AI/automation, business operations, e-commerce, personal productivity, technology trends.

### Step 2: Pull from Sources
- **Hacker News** -- fetch top 30 stories via API
- **Reddit** -- fetch posts from relevant subreddits (.json endpoint)
- **RSS feeds** -- fetch each configured feed URL
- **Newsletters** -- search Gmail for newsletter emails from last 24 hours

### Step 3: Filter
Remove:
- Duplicates (same story from multiple sources)
- Paywalled content
- Previously sent articles
- Low-quality material (clickbait, listicles unless genuinely useful)
- Purely promotional or marketing content

### Step 4: Select and Rank
Choose 5-10 articles meeting these criteria:
- Substantive -- teaches something or enables action
- Not paywalled
- Not a duplicate of recent coverage

Rank by: relevance to interests, source trustworthiness, recency.

### Step 5: Summarize
For each article provide:
- Title and source
- Direct link
- Estimated reading time
- 2-3 sentence summary of content and why it's worth reading

### Step 6: Save and Track
- Save as dated file to notes folder
- Track sent articles to avoid repeats
- If user has a read-later app (Pocket, Instapaper), send there too

## Output Format

### Reading List -- [Date]

1. **[Title]** -- [Source]
   [Link] | ~X min read
   [2-3 sentence summary]

2. **[Title]** -- [Source]
   [Link] | ~X min read
   [2-3 sentence summary]

[...up to 10]

## Rules
- Quality over quantity -- 5 great articles beats 15 mediocre ones
- NEVER auto-subscribe to any newsletter or service
- Skip purely promotional content
- If fewer than 5 articles meet the quality bar, deliver fewer rather than padding
- Rotate sources -- don't pull everything from one place
- If a source is down, skip it and note the issue
- Learn from feedback -- deprioritize topics the user consistently skips
