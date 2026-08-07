#!/usr/bin/env bash
set -euo pipefail

# Test the install script in isolation without affecting your real ~/.claude
#
# What this does:
# 1. Runs the install script with HOME=/tmp/claude-onboard-test
# 2. Shows you what was created
# 3. Prints the command to test /onboard manually
#
# To FULLY test the /onboard flow, have someone else run the one-liner
# on their machine, or use a fresh macOS user account.

TEST_HOME="/tmp/claude-onboard-test"

echo ""
echo "  Trestle - Test Mode"
echo "  Test HOME: $TEST_HOME"
echo ""

# Clean previous test
rm -rf "$TEST_HOME"
mkdir -p "$TEST_HOME"

# Run install with fake HOME
HOME="$TEST_HOME" bash "$(dirname "$0")/../install.sh"

echo "  Verifying install..."
echo ""

# Show what was created
echo "  Files created:"
find "$TEST_HOME/.claude" -type f | sort | while read f; do
  echo "    ${f#$TEST_HOME/}"
done

echo ""
echo "  CLAUDE.md contents:"
echo "  ---"
sed 's/^/  /' "$TEST_HOME/.claude/CLAUDE.md"
echo "  ---"
echo ""
for skill in onboard cq 73; do
  echo "  /$skill SKILL.md exists: $([ -f "$TEST_HOME/.claude/skills/$skill/SKILL.md" ] && echo 'yes' || echo 'NO')"
done
echo ""
echo "  Install script works correctly."
echo ""
echo "  To test the full /onboard flow:"
echo ""
echo "    macOS / Linux:"
echo "      git clone https://github.com/liormesh/trestle /tmp/trestle && /tmp/trestle/install.sh"
echo ""
echo "    Windows (PowerShell):"
echo "      git clone https://github.com/liormesh/trestle \$env:TEMP\\trestle; & \$env:TEMP\\trestle\\install.ps1"
echo ""
echo "    Then open Claude Code and type /onboard"
echo ""
echo "  Cleaning up test..."
rm -rf "$TEST_HOME"
echo "  Done."
echo ""
