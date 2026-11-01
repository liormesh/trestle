# Global Instructions

<!-- trestle:rules:start - managed by Trestle. `/onboard` option (d) refreshes this block; edit outside the markers. -->
## Knowledge System
- Knowledge base: {KB_PATH}
- Credentials: {KB_PATH}/_private/credentials.md (use autonomously for the services listed there, don't ask; never copy a value into another file)
- Memory index: MEMORY.md for persistent context; MEMORY-extended.md for full project/career details
- Skills: available via /skill-name - see `claude-skills/_index.md` for the catalog. Session rituals: `/cq <project>` to tune in, `/73` to sign off.
- **What's in flight?** Every project's `overview.md` carries `state: project | area | archive | icebox` + `state_changed:`. Answer with a grep (`state: project`), never from memory.
- **Live project status** lives in `pm/handoff/<project>-resume-prompt.md` (read first by `/cq`), not in MEMORY.md.

## Rules
- **MEMORY.md is governed by signal density and volatility, not line count.** Every line must affect behavior in ≥1-in-5 conversations. No live status in the index - stable hooks plus a pointer to the project's handoff doc. Soft cap ~100 lines as a smell test. Full guideline: `claude-memory/feedback-memory-size.md`.
- **No standalone feedback files.** Write feedback inline to the relevant KB file (skill, book chapter, project overview). Only cross-cutting behavioral rules stay in `claude-memory/`, named `<type>-<slug>.md` with `name:` = filename, and each gets a pointer line in MEMORY.md.
- **The memory sweep is triggered by `/73`** (it reports `SWEEP: OVERDUE` after 30 days), not by a calendar - `claude-memory/feedback-memory-decay.md`.
- **Don't create a skill until you've done the workflow manually 3+ times.** Log candidates in `claude-memory/project-skill-backlog.md`; check `claude-skills/_index.md` first - maybe an existing skill just needs a new mode.
- **Single source of truth.** The KB is authoritative. Write once, to the correct location. Moving a file = fix every link to it.
- **Secrets never go in a tracked file** - point to `_private/credentials.md` or an env var. The secret-guard hook blocks most of these writes; if one blocks you, reroute the value, don't rephrase around it.
- **Analytics.** After invoking a skill, append one line to `{KB_PATH}/_analytics/usage.log`, exactly: `<ISO-UTC timestamp> <skill-name> <short note>` (e.g. `2026-11-01T09:30:00Z visualize q3 report`). The health check parses it strictly.
<!-- trestle:rules:end -->
