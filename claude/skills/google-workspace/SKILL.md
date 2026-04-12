---
name: google-workspace
description: >
  Google Workspace tools: Gmail, Google Calendar, and Google Drive access.
  Use when the user asks about email, calendar, scheduling, or documents/files.
allowed-tools: Read, Bash, WebFetch
user-invocable: true
metadata:
  author: SGridworks
  version: 1.0.0
  category: productivity
  tags: [google, gmail, calendar, drive, workspace]
---

# Google Workspace Access

Account: adam@sgridworks.com
Timezone: America/New_York

## When to Use These Tools

**Act, don't ask.** When the user mentions email, calendar, scheduling, files,
documents, or Drive -- use the tools below immediately. Do not ask "do you have
access to Gmail?" or "would you like me to check your calendar?" -- you DO have
access. Use it.

Trigger phrases (not exhaustive):
- Email/mail/inbox/message/draft/newsletter -> Gmail tools
- Calendar/schedule/meeting/free time/availability -> Google Calendar tools
- Upload/download/document/file/Drive/spreadsheet/slides -> Google Drive tools
- Notion/page/database/wiki -> Notion tools

**Never ask for:**
- Account email (it's adam@sgridworks.com)
- Timezone (it's America/New_York)
- Credential paths (they're documented below)
- "Do you want me to check?" -- just check

## Gmail (claude.ai remote MCP)

Tools with prefix `mcp__claude_ai_Gmail__`:
- `gmail_search_messages` -- search with Gmail query syntax (from:, to:, subject:, is:unread, has:attachment, date ranges)
- `gmail_read_message` -- read full message by ID
- `gmail_read_thread` -- read entire conversation thread
- `gmail_create_draft` -- create draft emails (can reply to threads via threadId)
- `gmail_list_drafts` -- list saved drafts
- `gmail_list_labels` -- list all labels
- `gmail_get_profile` -- account info and stats

## Google Calendar (claude.ai remote MCP)

Tools with prefix `mcp__claude_ai_Google_Calendar__`:
- `gcal_list_events` -- list/search events in a time range
- `gcal_create_event` -- create events with attendees, recurrence, Google Meet
- `gcal_update_event` -- modify existing events
- `gcal_delete_event` -- cancel events
- `gcal_get_event` -- full details for one event
- `gcal_find_meeting_times` -- find mutual availability across attendees
- `gcal_find_my_free_time` -- find gaps in your schedule
- `gcal_list_calendars` -- list subscribed calendars
- `gcal_respond_to_event` -- RSVP to invitations

Timezone: America/New_York

## Google Drive

The local MCP server (`@piotr-agier/google-drive-mcp`) is **unreliable** -- it
often fails to register tools on session start. Use this decision tree:

**Step 1:** Check if gdrive MCP tools loaded this session (look for tools with
`gdrive` in the deferred tool list). If yes, use them.

**Step 2 (likely):** If MCP tools didn't load, use the REST API directly via Bash:

```bash
# 1. Read credentials
KEYS_FILE=~/.config/google-drive-mcp/gcp-oauth.keys.json
TOKENS_FILE=~/.config/google-drive-mcp/tokens.json
CLIENT_ID=$(python3 -c "import json; print(json.load(open('$KEYS_FILE'))['installed']['client_id'])")
CLIENT_SECRET=$(python3 -c "import json; print(json.load(open('$KEYS_FILE'))['installed']['client_secret'])")
REFRESH_TOKEN=$(python3 -c "import json; print(json.load(open('$TOKENS_FILE'))['refresh_token'])")

# 2. Get fresh access token
ACCESS_TOKEN=$(curl -s -X POST https://oauth2.googleapis.com/token \
  -d "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&refresh_token=$REFRESH_TOKEN&grant_type=refresh_token" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

# 3. Use the Drive API (examples)
# List files:
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files?q=name%20contains%20'search_term'&fields=files(id,name,mimeType)"

# Upload a file:
curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
  -F "metadata={name:'filename.pdf',parents:['folder_id']};type=application/json;charset=UTF-8" \
  -F "file=@/path/to/file" \
  "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"

# Download a file:
curl -s -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://www.googleapis.com/drive/v3/files/FILE_ID?alt=media" -o output_file
```

GCP Project: `claude-gdrive-488614`
Scopes: drive, drive.readonly, drive.file, documents, spreadsheets, presentations

## Notion (MCP)

Tools with prefix `mcp__notion__`:
- Search, create/retrieve/update pages, databases, blocks, comments, data sources
