# Handoffs - where live project status lives

Two files per project, both named after the project folder:

- **`<project>-resume-prompt.md`** - the living entry point. What `/cq <project>` reads first. Rewrite it in place: current finish line, what's in flight, what's blocked, the next step, gotchas for this week. Short - a new session should be oriented after reading it.
- **`<project>-handoff-log.md`** - append-only history, newest entry last. `/73` adds a few dated lines when a session moved the project: what changed, what was decided, what's next.

Why here and not in MEMORY.md: live status changes every week. In the always-loaded memory index it goes stale, gets edited constantly, and ends up disagreeing with the project doc. Here it is read only when you work on that project, and it lives in exactly one place.

The project's `overview.md` stays the stable description (what it is, stack, decisions, `state:`); keep it scannable - session logs go in the handoff log, not the overview.
