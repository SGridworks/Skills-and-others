#!/bin/bash
set -euo pipefail

# Skills-and-others Installer
# Creates symlinks from ~/.claude/ to this repo for shared config.
# Usage: ./install.sh [--target claude|cursor] [language...]
# Example: ./install.sh typescript python

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
      echo "Creates symlinks from ~/.claude/ into this repo so config"
      echo "stays in sync across machines via git pull."
      exit 0
      ;;
    *)
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
  claude) CLAUDE_DIR="$HOME/.claude" ;;
  cursor) CLAUDE_DIR="./.cursor" ;;
  *)
    echo "ERROR: Unknown target: $TARGET (use 'claude' or 'cursor')"
    exit 1
    ;;
esac

RULES_DIR="${CLAUDE_DIR}/rules"

echo "Installing Skills-and-others (symlink mode)..."
echo "Repo: ${SCRIPT_DIR}"
echo "Target: ${CLAUDE_DIR}"
echo ""

# Helper: create symlink, backing up existing file if not already a symlink to us
link_file() {
  local src="$1"
  local dst="$2"

  if [ -L "$dst" ]; then
    local current
    current="$(readlink "$dst")"
    if [ "$current" = "$src" ]; then
      echo "  OK (already linked): $(basename "$dst")"
      return
    fi
    rm "$dst"
  elif [ -e "$dst" ]; then
    local backup="${dst}.backup.$(date +%s)"
    mv "$dst" "$backup"
    echo "  Backed up: $(basename "$dst") -> $(basename "$backup")"
  fi

  ln -s "$src" "$dst"
  echo "  Linked: $(basename "$dst") -> ${src}"
}

# Helper: symlink all files in a source dir into a destination dir
link_dir_contents() {
  local src_dir="$1"
  local dst_dir="$2"

  mkdir -p "$dst_dir"
  for f in "$src_dir"/*; do
    [ -e "$f" ] || continue
    link_file "$f" "${dst_dir}/$(basename "$f")"
  done
}

# --- Rules ---
echo "Rules:"
mkdir -p "$RULES_DIR"

# Common rules
if [ -d "${SCRIPT_DIR}/rules/common" ]; then
  link_dir_contents "${SCRIPT_DIR}/rules/common" "$RULES_DIR"
fi

# Language-specific rules
for lang in "${LANGUAGES[@]}"; do
  if [ -d "${SCRIPT_DIR}/rules/${lang}" ]; then
    link_dir_contents "${SCRIPT_DIR}/rules/${lang}" "$RULES_DIR"
  else
    echo "  WARNING: No rules found for language: ${lang}"
  fi
done

# --- Skills ---
echo ""
echo "Skills:"
SKILLS_DIR="${CLAUDE_DIR}/skills"
mkdir -p "$SKILLS_DIR"

for skill_dir in "${SCRIPT_DIR}/skills/"*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  dst="${SKILLS_DIR}/${skill_name}"

  if [ -L "$dst" ]; then
    current="$(readlink "$dst")"
    if [ "$current" = "$skill_dir" ] || [ "$current" = "${skill_dir%/}" ]; then
      echo "  OK (already linked): ${skill_name}/"
      continue
    fi
    rm "$dst"
  elif [ -d "$dst" ]; then
    backup="${dst}.backup.$(date +%s)"
    mv "$dst" "$backup"
    echo "  Backed up: ${skill_name}/ -> $(basename "$backup")"
  fi

  ln -s "${skill_dir%/}" "$dst"
  echo "  Linked: ${skill_name}/ -> ${skill_dir%/}"
done

# --- Claude-only targets ---
if [ "$TARGET" = "claude" ]; then

  # Hooks
  echo ""
  echo "Hooks:"
  HOOKS_DIR="${CLAUDE_DIR}/hooks"
  if [ -d "${SCRIPT_DIR}/.claude/hooks" ]; then
    link_dir_contents "${SCRIPT_DIR}/.claude/hooks" "$HOOKS_DIR"
    chmod +x "$HOOKS_DIR/"*.sh 2>/dev/null || true
  fi

  # Settings
  echo ""
  echo "Settings:"
  link_file "${SCRIPT_DIR}/settings.json" "${CLAUDE_DIR}/settings.json"
  if [ -f "${SCRIPT_DIR}/settings.local.json" ]; then
    link_file "${SCRIPT_DIR}/settings.local.json" "${CLAUDE_DIR}/settings.local.json"
  fi

  # CLAUDE.md — only install if not present (user customizes per-machine)
  echo ""
  echo "CLAUDE.md:"
  if [ ! -e "${CLAUDE_DIR}/CLAUDE.md" ]; then
    if [ -f "${SCRIPT_DIR}/examples/user-CLAUDE.md" ]; then
      cp "${SCRIPT_DIR}/examples/user-CLAUDE.md" "${CLAUDE_DIR}/CLAUDE.md"
      echo "  Installed: CLAUDE.md (from template — customize for this machine)"
    fi
  else
    echo "  Skipped: CLAUDE.md already exists (per-machine file, not symlinked)"
  fi

  # Theologian SOUL.md (referenced by skill, needs to be at ~/.claude/theologian/)
  echo ""
  echo "Theologian identity:"
  THEO_DIR="${CLAUDE_DIR}/theologian"
  mkdir -p "$THEO_DIR"
  link_file "${SCRIPT_DIR}/skills/theologian/SOUL.md" "${THEO_DIR}/SOUL.md"
fi

echo ""
echo "Installation complete!"
echo ""
echo "To sync on another machine:"
echo "  git clone https://github.com/SGridworks/Skills-and-others.git ~/Skills-and-others"
echo "  cd ~/Skills-and-others && ./install.sh typescript python"
echo ""
echo "To update after a git pull:"
echo "  ./install.sh typescript python  (safe to re-run, idempotent)"
