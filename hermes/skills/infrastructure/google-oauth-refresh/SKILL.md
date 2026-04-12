---
name: google-oauth-refresh
description: Google OAuth token refresh pattern — bypasses google-auth library scope bug that causes invalid_grant errors
triggers:
  - "Google OAuth token expired"
  - "invalid_grant: Token has been revoked"
  - "Google API 401 after token refresh"
category: infrastructure
---

# Google OAuth Token Refresh Pattern

## Problem
Google OAuth tokens expire in 1 hour. `google-auth` library's scope parsing during refresh reformats scopes as space-separated but server returns newline-separated — causes "invalid_grant: Token has been revoked" errors.

## Working Token File
`~/.config/google-drive-mcp/tokens.json` — format:
```json
{
  "access_token": "...",
  "refresh_token": "...",
  "client_id": "from gcp-oauth.keys.json",
  "client_secret": "from gcp-oauth.keys.json",
  "token_uri": "https://oauth2.googleapis.com/token",
  "scopes": ["https://www.googleapis.com/auth/gmail.readonly", ...],
  "expiry": "2026-03-23T00:00:00.000Z"
}
```

## Compatible Script Pattern (bypasses google-auth library)
```python
import json, requests
from google.oauth2.credentials import Credentials

# Load raw token
with open(os.path.expanduser("~/.config/google-drive-mcp/tokens.json")) as f:
    data = json.load(f)

creds = Credentials(
    token=data["access_token"],
    refresh_token=data["refresh_token"],
    token_uri=data.get("token_uri", "https://oauth2.googleapis.com/token"),
    client_id=data["client_id"],
    client_secret=data["client_secret"],
    scopes=data.get("scopes"),
)

from google.auth.transport import requests as garequests
creds.refresh(garequests.Request())
print(creds.token)
```

## GCP OAuth Keys Location
`~/.config/google-drive-mcp/gcp-oauth.keys.json` — correct OAuth client
NOT `~/.hermes/google_client_secret.json` (wrong client_id)

## Cron Job Scripts
- `~/.hermes/scripts/email_triage.py`
- `~/.hermes/scripts/randomize_booking.py`

## Fastest Token Refresh (curl, no Python)

For scripts that just need a fresh access token:
```bash
KEYS_FILE=~/.config/google-drive-mcp/gcp-oauth.keys.json
TOKENS_FILE=~/.config/google-drive-mcp/tokens.json
CLIENT_ID=$(python3 -c "import json; print(json.load(open('$KEYS_FILE'))['installed']['client_id'])")
CLIENT_SECRET=$(python3 -c "import json; print(json.load(open('$KEYS_FILE'))['installed']['client_secret'])")
REFRESH_TOKEN=$(python3 -c "import json; print(json.load(open('$TOKENS_FILE'))['refresh_token'])")

ACCESS_TOKEN=$(curl -s -X POST https://oauth2.googleapis.com/token \
  -d "client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&refresh_token=$REFRESH_TOKEN&grant_type=refresh_token" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
```

## Pitfalls
- Do NOT use `~/.hermes/google_client_secret.json` for OAuth (wrong client_id)
- Do NOT use google_auth library auto-refresh in long-running processes (scope parsing bug)
- The Claude Code `/google-workspace` skill now has the full REST API fallback for Drive
