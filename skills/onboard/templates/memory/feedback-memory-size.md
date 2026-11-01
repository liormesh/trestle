---
name: feedback-memory-size
description: MEMORY.md is loaded into every conversation - govern it by signal density and volatility, not line count
metadata:
  type: feedback
  trestle: 1.8.0
---

Every line in MEMORY.md must change Claude's behavior in **at least 1-in-5 conversations**. If a rule only matters for one workflow, project, or audience, inline it in that workflow's KB doc instead.

**The primary rule: no live status in the index.** MEMORY.md holds stable behavioral hooks plus a pointer to each project's doc. Anything that changes week to week - "launching Thursday", "waiting on legal", "trial ends 3 Nov", which sprint you're in - lives in the project's handoff doc (`pm/handoff/<project>-resume-prompt.md`) or its overview, and MEMORY.md only points there.

**Why:** MEMORY.md is auto-loaded into every conversation, so it is the most expensive real estate in the workspace. Two things go wrong with it, and line count only catches the smaller one:
- **Density** - when everything is flagged "important," nothing is.
- **Volatility** - volatile status is what drives constant edits. Every edit re-writes the always-loaded prefix (which defeats prompt caching, so each session pays full price again), and it creates two places that must agree: the index says "launching Thursday," the project doc says it slipped. One of them is now lying, and it is usually the one loaded every time. Status in one place, pointers everywhere else.

**How to apply:**
- Before adding a line, ask: "Does this affect Claude's behavior in at least 1-in-5 random conversations?" If no, inline it elsewhere
- Before adding a line with a date, a deadline or "as of" in it, ask: "Will this be false in two weeks?" If yes, it belongs in the handoff doc. `/73`'s health check counts dated lines in MEMORY.md so creep is visible
- Soft cap of ~100 lines as a smell test, not a target. Reaching for line 100 means delete, move to MEMORY-extended.md, or run the memory sweep - not bend the rule
- Prefer pointers over copies: a pointer to a KB doc never goes stale; a copied fact does
- MEMORY-extended.md is the no-limit overflow (loaded on demand)

**What belongs in MEMORY.md:**
- Identity (who, role, location, languages)
- Active projects - one pointer line each, no status
- Cross-cutting behavioral rules and corrections
- Cross-project tooling that's load-bearing
- Pointer to MEMORY-extended.md

**What does NOT belong:**
- Project-specific rules - inline in `projects/<name>/overview.md`
- Audience-specific rules - inline in that audience's content doc
- Live status, deadlines, this-week state - `pm/handoff/<project>-resume-prompt.md`
- Project state (active / maintained / parked) - the `state:` field on the project's overview, queried with a grep
- Anything derivable from `git log`, code, or a quick KB grep
