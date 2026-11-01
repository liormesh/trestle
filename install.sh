#!/usr/bin/env bash
set -euo pipefail

# Trestle - Installer
# One-liner: git clone https://github.com/liormesh/trestle /tmp/trestle && /tmp/trestle/install.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
TRESTLE_DIR="$CLAUDE_DIR/trestle"
VERSION="$(cat "$SCRIPT_DIR/tools/VERSION")"
BACKUP_DIR="$TRESTLE_DIR/backups/$(date +%Y%m%d-%H%M%S)"
UPDATED=0

echo ""
echo "  Trestle v$VERSION"
echo "  ─────────────────"
echo ""
echo "  Installing to: $CLAUDE_DIR"
echo ""
echo "  What this does:"
echo "    1. Copies the starter skills (/onboard, /cq, /73, /visualize) to $SKILLS_DIR/"
echo "       (already installed? older copies are backed up, then updated)"
echo "    2. Copies three small tools to $TRESTLE_DIR/ - a secret guard, a link guard"
echo "       and the /73 health check (Node.js scripts, no dependencies)"
echo "    3. Creates a bootstrap CLAUDE.md (triggers /onboard on first run)"
echo ""
echo "  That's it - a handful of files. The real setup happens when you type /onboard."
echo ""

# 1. Ensure ~/.claude exists
mkdir -p "$CLAUDE_DIR"
mkdir -p "$SKILLS_DIR"

# 2. Copy the starter skills (onboard + the session rituals cq / 73 + the /visualize skill and its book).
#    An existing copy that differs is backed up first, then replaced - that is the upgrade path.
for skill in onboard cq 73 visualize; do
  if [ -d "$SKILLS_DIR/$skill" ]; then
    if diff -rq "$SCRIPT_DIR/skills/$skill" "$SKILLS_DIR/$skill" >/dev/null 2>&1; then
      echo "  [ok]   /$skill skill is up to date"
      continue
    fi
    mkdir -p "$BACKUP_DIR/skills"
    mv "$SKILLS_DIR/$skill" "$BACKUP_DIR/skills/$skill"
    cp -r "$SCRIPT_DIR/skills/$skill" "$SKILLS_DIR/$skill"
    UPDATED=1
    echo "  [done] Updated /$skill skill (previous copy → $BACKUP_DIR/skills/$skill)"
  else
    cp -r "$SCRIPT_DIR/skills/$skill" "$SKILLS_DIR/$skill"
    echo "  [done] Installed /$skill skill → $SKILLS_DIR/$skill/"
  fi
done

# 2b. Tools: hooks + health check (config.json, written by /onboard, is never touched here)
mkdir -p "$TRESTLE_DIR"
[ -f "$TRESTLE_DIR/VERSION" ] && [ "$(cat "$TRESTLE_DIR/VERSION")" != "$VERSION" ] && UPDATED=1
cp "$SCRIPT_DIR"/tools/*.mjs "$SCRIPT_DIR/tools/VERSION" "$TRESTLE_DIR/"
echo "  [done] Installed tools → $TRESTLE_DIR/ (v$VERSION)"

if command -v node >/dev/null 2>&1 && [ "$(node -p 'process.versions.node.split(".")[0]')" -ge 18 ]; then
  echo "  [ok]   Node.js $(node --version) found"
else
  echo "  [warn] Node.js 18+ not found - the hooks and the /73 health check need it (https://nodejs.org)"
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
if [ "$UPDATED" = 1 ] && [ -f "$TRESTLE_DIR/config.json" -o -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  echo "  Updated to v$VERSION. Open Claude Code from your home directory (cd ~), type /onboard"
  echo "  and pick (d) to bring your workspace's rules up to date. Your content is not touched."
else
  echo "  Ready. Open Claude Code from your home directory (cd ~) and type /onboard."
fi
echo ""
