#!/bin/bash
set -euo pipefail

# Claude Code Configuration Installer
# Usage: ./install.sh [--target claude|cursor] [language...]
# Example: ./install.sh typescript python
# Example: ./install.sh --target cursor typescript

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET="claude"
LANGUAGES=()

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 [--target claude|cursor] [language...]"
      echo ""
      echo "Languages: typescript, python, golang"
      echo "Targets: claude (default), cursor"
      echo ""
      echo "Examples:"
      echo "  $0 typescript           # Install TypeScript rules for Claude Code"
      echo "  $0 --target cursor python  # Install Python rules for Cursor"
      echo "  $0 typescript python    # Install both"
      exit 0
      ;;
    *)
      # Validate language (prevent path traversal)
      if [[ "$1" =~ ^[a-zA-Z]+$ ]]; then
        LANGUAGES+=("$1")
      else
        echo "ERROR: Invalid language: $1"
        exit 1
      fi
      shift
      ;;
  esac
done

# Determine destination
case "$TARGET" in
  claude)
    RULES_DIR="$HOME/.claude/rules"
    ;;
  cursor)
    RULES_DIR="./.cursor/rules"
    ;;
  *)
    echo "ERROR: Unknown target: $TARGET (use 'claude' or 'cursor')"
    exit 1
    ;;
esac

echo "Installing Claude Code configuration..."
echo "Target: $TARGET"
echo "Rules directory: $RULES_DIR"

# Install common rules
mkdir -p "$RULES_DIR"
if [ -d "${SCRIPT_DIR}/rules/common" ]; then
  echo "Installing common rules..."
  cp "${SCRIPT_DIR}/rules/common/"*.md "$RULES_DIR/"
  echo "  Installed: $(ls "${SCRIPT_DIR}/rules/common/"*.md | wc -l | tr -d ' ') common rules"
fi

# Install language-specific rules
for lang in "${LANGUAGES[@]}"; do
  if [ -d "${SCRIPT_DIR}/rules/${lang}" ]; then
    echo "Installing ${lang} rules..."
    cp "${SCRIPT_DIR}/rules/${lang}/"*.md "$RULES_DIR/"
    echo "  Installed: $(ls "${SCRIPT_DIR}/rules/${lang}/"*.md | wc -l | tr -d ' ') ${lang} rules"
  else
    echo "WARNING: No rules found for language: ${lang}"
  fi
done

# Install hooks (Claude target only)
if [ "$TARGET" = "claude" ]; then
  HOOKS_DIR="$HOME/.claude/hooks"
  if [ -d "${REPO_DIR}/.claude/hooks" ]; then
    echo "Installing hooks..."
    mkdir -p "$HOOKS_DIR"
    cp "${REPO_DIR}/.claude/hooks/"*.sh "$HOOKS_DIR/"
    chmod +x "$HOOKS_DIR/"*.sh
    echo "  Installed: $(ls "${REPO_DIR}/.claude/hooks/"*.sh | wc -l | tr -d ' ') hooks"
  fi

  # Install user-level CLAUDE.md (won't overwrite existing)
  USER_CLAUDE="$HOME/.claude/CLAUDE.md"
  if [ ! -f "$USER_CLAUDE" ]; then
    if [ -f "${SCRIPT_DIR}/examples/user-CLAUDE.md" ]; then
      cp "${SCRIPT_DIR}/examples/user-CLAUDE.md" "$USER_CLAUDE"
      echo "  Installed: user-level CLAUDE.md"
    fi
  else
    echo "  Skipped: ~/.claude/CLAUDE.md already exists (not overwriting)"
  fi
fi

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Review installed rules in: $RULES_DIR"
if [ "$TARGET" = "claude" ]; then
  echo "  2. Review ~/.claude/CLAUDE.md and customize for your preferences"
  echo "  3. Copy relevant MCP configs from claude/mcp-configs/ to your project"
  echo "  4. Create a project-specific CLAUDE.md (see claude/examples/ for templates)"
fi
