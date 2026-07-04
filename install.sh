#!/usr/bin/env bash
set -euo pipefail

# Trestle — Installer
# One-liner: git clone https://github.com/liormesh/trestle /tmp/trestle && /tmp/trestle/install.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"

echo ""
echo "  Trestle"
echo "  ─────────────────"
echo ""
echo "  Installing to: $CLAUDE_DIR"
echo ""
echo "  What this does:"
echo "    1. Copies the starter skills (/onboard, /cq, /73) to $SKILLS_DIR/"
echo "    2. Creates a bootstrap CLAUDE.md (triggers /onboard on first run)"
echo ""
echo "  That's it — a handful of files. The real setup happens when you type /onboard."
echo ""

# 1. Ensure ~/.claude exists
mkdir -p "$CLAUDE_DIR"
mkdir -p "$SKILLS_DIR"

# 2. Copy the starter skills (onboard + the session rituals cq / 73)
for skill in onboard cq 73; do
  if [ -d "$SKILLS_DIR/$skill" ]; then
    echo "  [skip] /$skill skill already installed"
  else
    cp -r "$SCRIPT_DIR/skills/$skill" "$SKILLS_DIR/$skill"
    echo "  [done] Installed /$skill skill → $SKILLS_DIR/$skill/"
  fi
done

# 3. Create bootstrap CLAUDE.md (only if none exists)
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  echo "  [skip] ~/.claude/CLAUDE.md already exists"
else
  cat > "$CLAUDE_DIR/CLAUDE.md" << 'EOF'
# First Time Setup

If no knowledge base exists yet (no ~/Documents/knowledge-base/ or the user hasn't been onboarded), suggest running /onboard to set up their AI workspace. This is a one-time setup that creates a personal knowledge base, memory system, and profile.

After onboarding is complete, this file will be replaced with permanent global instructions.
EOF
  echo "  [done] Created bootstrap CLAUDE.md"
fi

# 4. Clean up clone if installed from /tmp
if [[ "$SCRIPT_DIR" == /tmp/* ]]; then
  rm -rf "$SCRIPT_DIR"
  echo "  [done] Cleaned up temporary files"
fi

echo ""
echo "  Ready. Open Claude Code from your home directory (cd ~) and type /onboard."
echo ""
