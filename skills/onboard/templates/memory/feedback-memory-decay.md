---
name: feedback-memory-decay
description: The memory sweep - promote what's load-bearing, archive what's stale - triggered by /73, not by a calendar
metadata:
  type: feedback
  trestle: 1.8.0
---

Memory and the KB accumulate. Left unattended, MEMORY.md fills with stale status and one-off notes, and the signal-density rule quietly rots. The sweep is the fix.

**When:** `/73` runs a health check at every sign-off. When 30+ days have passed since the last sweep it reports `SWEEP: OVERDUE` and adds "run the memory sweep" to the action items - so the next session starts with it. Also run one whenever MEMORY.md crosses ~100 lines.

**Why ritual, not calendar:** in real use, everything scheduled as "do this monthly" quietly stopped happening, while everything attached to a ritual that already fires (session open, session close) kept running. So the sweep has no calendar slot. The sign-off notices it is due.

**How to run it - three buckets per line/file:**
- **Active** - still changes behavior in ~1-in-5 sessions. Keep it in MEMORY.md.
- **Archive** - was true, no longer load-bearing. Move to MEMORY-extended.md or the relevant project doc; delete if fully superseded.
- **Promote** - a correction you've repeated across sessions that isn't captured yet, or several memory files saying the same thing. Write or merge it into its correct home (inline per the no-standalone-feedback rule).

Then:
1. Run `node ~/.claude/trestle/kb-check.mjs --usage 30` - skills nobody used are dead weight (or have a description that never triggers); recurring manual work belongs in `project-skill-backlog.md`.
2. Check stale projects: anything `state: project` that hasn't moved in 45 days gets a new finish line or moves to `area` / `archive`.
3. Log it, so the next check knows: append `<ISO-UTC> memory-sweep <N archived, N promoted>` to `_analytics/usage.log`.

Show the proposed buckets to the user before moving or deleting anything.
