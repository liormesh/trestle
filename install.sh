#!/usr/bin/env bash
set -euo pipefail

# Claude Onboard Kit — Installer
# One-liner: git clone https://github.com/liormesh/claude-onboard-kit /tmp/claude-onboard-kit && /tmp/claude-onboard-kit/install.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"

echo ""
echo "  Claude Onboard Kit"
echo "  ─────────────────"
echo ""
echo "  Installing to: $CLAUDE_DIR"
echo ""
echo "  What this does:"
echo "    1. Copies the /onboard skill to $SKILLS_DIR/onboard/"
echo "    2. Creates a bootstrap CLAUDE.md (triggers /onboard on first run)"
echo ""
echo "  That's it — two files. The real setup happens when you type /onboard."
echo ""

# 1. Ensure ~/.claude exists
mkdir -p "$CLAUDE_DIR"
mkdir -p "$SKILLS_DIR"

# 2. Copy the /onboard skill
if [ -d "$SKILLS_DIR/onboard" ]; then
  echo "  [skip] /onboard skill already installed"
else
  cp -r "$SCRIPT_DIR/skills/onboard" "$SKILLS_DIR/onboard"
  echo "  [done] Installed /onboard skill → $SKILLS_DIR/onboard/"
fi

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
echo "  Ready. Open Claude Code and type /onboard to get started."
echo ""
