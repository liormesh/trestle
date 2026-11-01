---
name: cq
description: Calling a project - tune this session into one project's full context (handoff doc, overview, state, gotchas) before working. Triggers on '/cq <project>', 'work on <project>', 'load <project>', 'tune into <project>'.
---

# /cq - Calling a project

`/cq` is the radio opening call ("seeking contact") - the user wants to tune this session into a specific project's frequency before you work. The project is: **$ARGUMENTS**

Load that project's context now, then confirm you're tuned in. This is the **Context leg** in action: pull the right context at the right moment, instead of re-briefing from scratch every session.

## Steps

1. **Resolve the project.** Map `$ARGUMENTS` to a folder in the knowledge base's `projects/`. If empty, list the projects whose overview says `state: project` (what's in flight - grep, don't guess from memory) and ask which one. If ambiguous, list the closest matches and ask.

2. **Read its context, in this order (skip any that don't exist):**
   - **The resume prompt:** `pm/handoff/<project>-resume-prompt.md` - live status, finish line, next step. Read this first; it's written to orient a fresh session.
   - **The overview:** `projects/<project>/overview.md` - the stable description, its `state:`, the health-check command, key decisions.
   - Anything either of them points to as a must-read for this kind of work (deploy notes, known footguns). Don't read the handoff *log* unless the resume prompt is missing or you need history.

3. **Surface the project's own rules** - anything in MEMORY or the project docs that changes how you should behave on *this* project (where it deploys, which credential to use, conventions to respect).

4. **Check the state.** If the overview says `state: project` but `state_changed` is 45+ days old, say so in one line: a project is supposed to finish - is there still a finish line, or is this now an `area` / `archive`? If it's `area`, treat the session as maintenance; `archive` / `icebox`, confirm the user means to reopen it (and offer to flip it to `project` with today's date).

5. **Run a health check if this is a coding session** (per `feedback-health-check.md`) - run the command in the overview's `## Health Check` section before writing code. Skip for read-only work.

6. **Report back, briefly:**
   - What frequency we're on - project, its state, and the current finish line.
   - Live action items / open threads (from the resume prompt).
   - The gotchas you'll respect this session.
   - What you read to get there.
   Then ask what we're doing.

This is **read-and-orient only** - don't change anything until the user says what the task is. Append `<ISO-UTC> cq <project>` to `_analytics/usage.log`.
