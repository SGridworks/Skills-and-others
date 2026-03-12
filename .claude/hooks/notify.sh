#!/bin/bash
set -euo pipefail

# macOS notification when Claude needs attention.
# Reads the notification title/message from CLAUDE_NOTIFICATION (JSON).

TITLE="${CLAUDE_NOTIFICATION_TITLE:-Claude Code}"
MESSAGE="${CLAUDE_NOTIFICATION_BODY:-Needs your attention}"

osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" 2>/dev/null || true

exit 0
