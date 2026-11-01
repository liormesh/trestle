#!/usr/bin/env bash
# Tests the Trestle tools (hooks + kb-check) against a throwaway fixture workspace with
# known defects planted in it. Never touches your real ~/.claude or knowledge base.
#   bash dev/test-tools.sh
set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
T="$(mktemp -d)"
export HOME="$T/home"
KB="$HOME/kb"
MEM="$HOME/.claude/projects/-home/memory"
TOOLS="$REPO/tools"
fails=0
pass() { echo "  ok   $1"; }
fail() { echo "  FAIL $1"; fails=$((fails+1)); }
expect() { # expect <name> <haystack> <needle>
  if printf '%s' "$2" | grep -qF -- "$3"; then pass "$1"; else fail "$1 (missing: $3)"; printf '%s\n' "$2" | sed 's/^/       | /'; fi
}

# ---------- fixture ----------
mkdir -p "$KB/projects/acme" "$KB/me" "$KB/_analytics" "$KB/_private" "$MEM" "$HOME/.claude/trestle"
ln -s "$MEM" "$KB/claude-memory"
cat > "$HOME/.claude/trestle/config.json" <<EOF
{ "kb_path": "$KB", "memory_path": "$MEM", "workspace_version": "1.8.0", "installed": "2026-01-01" }
EOF
cp "$TOOLS/VERSION" "$HOME/.claude/trestle/VERSION" 2>/dev/null || true

cat > "$KB/me/profile.md" <<'EOF'
# Profile
EOF
cat > "$KB/projects/acme/overview.md" <<'EOF'
---
title: Acme
state: project
state_changed: 2026-01-01
---
# Acme
See [profile](../../me/profile.md) and [[missing-note]].
`[[ignored-in-code]]`
EOF
cat > "$KB/projects/acme/spec.md" <<'EOF'
---
title: Acme spec
state: area
---
# Spec
EOF
FAKE_KEY="sk-ant-$(printf 'A%.0s' {1..30})"
printf '# Notes\nkey: %s\n' "$FAKE_KEY" > "$KB/me/notes.md"
printf 'key: %s\n' "$FAKE_KEY" > "$KB/_private/credentials.md"
cat > "$MEM/MEMORY.md" <<'EOF'
# Test - Persistent Context
- `feedback-health-check.md` - run a build check
EOF
cat > "$MEM/feedback-health-check.md" <<'EOF'
---
name: feedback-health-check
description: Run a build check before coding
metadata:
  type: feedback
---
Body.
EOF
cat > "$MEM/feedback_old.md" <<'EOF'
---
name: Old rule
description: legacy
type: feedback
---
EOF
printf '2026-01-01T00:00:00Z onboard first run\nnot a valid line\n' > "$KB/_analytics/usage.log"

echo ""
echo "  kb-check"
out="$(node "$TOOLS/kb-check.mjs" 2>&1)"; code=$?
expect "exit code 1 on WARN"            "$code" "1"
expect "broken wikilink found"          "$out" "[[missing-note]]"
if printf '%s' "$out" | grep -q "ignored-in-code"; then fail "links inside code are ignored"; else pass "links inside code are ignored"; fi
expect "secret found + masked"          "$out" "sk-ant...(37 chars)"
if printf '%s' "$out" | grep -q "_private/credentials.md:"; then fail "_private is exempt"; else pass "_private is exempt"; fi
expect "underscore memory filename"     "$out" "feedback_old.md: underscore filename"
expect "name != filename"               "$out" 'name "Old rule" != filename'
expect "nested metadata.type accepted"  "$(printf '%s' "$out" | grep -c 'feedback-health-check.md: no type')" "0"
expect "unindexed memory file"          "$out" "claude-memory/feedback_old.md"
expect "state on a sub-doc"             "$out" "spec.md: state: on a sub-doc"
expect "stale project"                  "$out" "STALE: 1 project(s)"
expect "sweep overdue"                  "$out" "SWEEP: OVERDUE"
expect "malformed analytics line"       "$out" "ANALYTICS: 1 usage.log line"
expect "baseline created"               "$out" "RATCHET: baseline created"

# ratchet: add a second broken link -> must WARN; remove both -> must tighten
echo "[[another-missing]]" >> "$KB/me/profile.md"
out="$(node "$TOOLS/kb-check.mjs" 2>&1)"
expect "ratchet catches a rise"         "$out" "RATCHET: WARN - vault-wide count went up: broken_links 1 -> 2"
printf '# Profile\n' > "$KB/me/profile.md"
sed -i.bak 's/\[\[missing-note\]\]/[profile](..\/..\/me\/profile.md)/' "$KB/projects/acme/overview.md" && rm -f "$KB/projects/acme/overview.md.bak"
out="$(node "$TOOLS/kb-check.mjs" 2>&1)"
expect "ratchet tightens on a fall"     "$out" "tightened: broken_links=0"

out="$(node "$TOOLS/kb-check.mjs" --usage 100000 2>&1)"
expect "usage mode counts skills"       "$out" "onboard"
expect "usage mode flags malformed"     "$out" "1 malformed"

echo ""
echo "  secret-guard (PreToolUse)"
payload() { node -e 'console.log(JSON.stringify({tool_name:process.argv[1],tool_input:JSON.parse(process.argv[2])}))' "$1" "$2"; }
p="$(payload Write "{\"file_path\":\"$KB/me/x.md\",\"content\":\"token $FAKE_KEY\"}")"
err="$(printf '%s' "$p" | node "$TOOLS/secret-guard.mjs" 2>&1 >/dev/null)"; code=$?
expect "blocks secret in KB (exit 2)"   "$code" "2"
expect "explains where it goes"         "$err" "_private/credentials.md"
p="$(payload Edit "{\"file_path\":\"$MEM/feedback-x.md\",\"old_string\":\"a\",\"new_string\":\"$FAKE_KEY\"}")"
printf '%s' "$p" | node "$TOOLS/secret-guard.mjs" >/dev/null 2>&1; expect "blocks secret in memory (Edit)" "$?" "2"
p="$(payload Write "{\"file_path\":\"$KB/_private/credentials.md\",\"content\":\"$FAKE_KEY\"}")"
printf '%s' "$p" | node "$TOOLS/secret-guard.mjs" >/dev/null 2>&1; expect "allows _private/" "$?" "0"
p="$(payload Write "{\"file_path\":\"$T/elsewhere/app.env\",\"content\":\"$FAKE_KEY\"}")"
printf '%s' "$p" | node "$TOOLS/secret-guard.mjs" >/dev/null 2>&1; expect "ignores files outside the workspace" "$?" "0"
p="$(payload Write "{\"file_path\":\"$KB/me/x.md\",\"content\":\"no secrets, just sk-ant-XXXX\"}")"
printf '%s' "$p" | node "$TOOLS/secret-guard.mjs" >/dev/null 2>&1; expect "allows visibly fake keys" "$?" "0"

echo ""
echo "  link-guard (PostToolUse)"
p="$(payload Write "{\"file_path\":\"$KB/projects/acme/new.md\",\"content\":\"[ok](../../me/profile.md) [[profle]] [bad](./nope.md)\"}")"
err="$(printf '%s' "$p" | node "$TOOLS/link-guard.mjs" 2>&1 >/dev/null)"; code=$?
expect "reports broken links (exit 2)"  "$code" "2"
expect "counts only the broken ones"    "$err" "2 link(s)"
expect "did-you-mean suggestion"        "$err" "did you mean me/profile.md"
p="$(payload Edit "{\"file_path\":\"$KB/me/profile.md\",\"old_string\":\"a\",\"new_string\":\"see [[overview]]\"}")"
printf '%s' "$p" | node "$TOOLS/link-guard.mjs" >/dev/null 2>&1; expect "passes good wikilinks" "$?" "0"
p="$(payload Write "{\"file_path\":\"$KB/script.py\",\"content\":\"[[nothing]]\"}")"
printf '%s' "$p" | node "$TOOLS/link-guard.mjs" >/dev/null 2>&1; expect "ignores non-markdown" "$?" "0"

rm -rf "$T"
echo ""
if [ "$fails" -eq 0 ]; then echo "  All tool tests passed."; else echo "  $fails test(s) FAILED."; fi
echo ""
exit $fails
