#!/usr/bin/env bash
set -euo pipefail

# Claude Onboard Kit — Installer
# One-liner: git clone https://github.com/liormesh/claude-onboard-kit /tmp/claude-onboard-kit && /tmp/claude-onboard-kit/install.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"

echo ""
echo "  Claude Onboard Kit — Setting up..."
echo ""

# 1. Ensure ~/.claude exists
mkdir -p "$CLAUDE_DIR"
mkdir -p "$SKILLS_DIR"

# 2. Copy the /onboard skill
if [ -d "$SKILLS_DIR/onboard" ]; then
  echo "  [skip] /onboard skill already installed"
else
  cp -r "$SCRIPT_DIR/skills/onboard" "$SKILLS_DIR/onboard"
  echo "  [done] Installed /onboard skill"
fi

# 3. Create bootstrap CLAUDE.md (only if none exists)
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  echo "  [skip] ~/.claude/CLAUDE.md already exists"
else
  cat > "$CLAUDE_DIR/CLAUDE.md" << 'EOF'
# First Time Setup

If no knowledge base exists at ~/Documents/knowledge-base/, suggest running /onboard to set up the user's AI workspace. This is a one-time setup that creates a personal knowledge base, memory system, and profile.

After onboarding is complete, this file will be replaced with permanent global instructions.
EOF
  echo "  [done] Created bootstrap ~/.claude/CLAUDE.md"
fi

# 4. Clean up clone if installed from /tmp
if [[ "$SCRIPT_DIR" == /tmp/* ]]; then
  rm -rf "$SCRIPT_DIR"
  echo "  [done] Cleaned up temporary files"
fi

echo ""
echo "  All set! Open Claude Code and type /onboard to get started."
echo ""
