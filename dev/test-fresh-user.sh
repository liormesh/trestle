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
fails=0
check() { if eval "$2"; then echo "  ok   $1"; else echo "  FAIL $1"; fails=$((fails+1)); fi; }
for skill in onboard cq 73 visualize; do
  check "/$skill SKILL.md installed" "[ -f '$TEST_HOME/.claude/skills/$skill/SKILL.md' ]"
done
for f in secret-guard.mjs link-guard.mjs kb-check.mjs lib.mjs VERSION; do
  check "tool $f installed" "[ -f '$TEST_HOME/.claude/trestle/$f' ]"
done
for f in memory/feedback-memory-size.md kb/claude-md.md kb/gitignore kb/handoff-readme.md; do
  check "template $f shipped" "[ -f '$TEST_HOME/.claude/skills/onboard/templates/$f' ]"
done

echo ""
echo "  Upgrade path: re-run over an edited install..."
echo "# local edit" >> "$TEST_HOME/.claude/skills/73/SKILL.md"
out="$(HOME="$TEST_HOME" bash "$(dirname "$0")/../install.sh")"
check "re-run is up to date for untouched skills" "printf '%s' \"\$out\" | grep -q '/cq skill is up to date'"
check "edited skill gets updated" "printf '%s' \"\$out\" | grep -q 'Updated /73 skill'"
check "previous copy backed up" "ls '$TEST_HOME'/.claude/trestle/backups/*/skills/73/SKILL.md >/dev/null 2>&1"
check "backup holds the local edit" "grep -q '# local edit' '$TEST_HOME'/.claude/trestle/backups/*/skills/73/SKILL.md"
check "no stray skill dirs in skills/" "[ \$(ls '$TEST_HOME/.claude/skills' | wc -l) -eq 4 ]"

echo ""
bash "$(dirname "$0")/test-tools.sh" || fails=$((fails+1))

[ "$fails" -eq 0 ] && echo "  Install script works correctly." || { echo "  $fails install check(s) FAILED."; }
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
exit $fails
