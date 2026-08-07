---
name: 73
description: Sign-off - end-of-session checklist. Confirms it's safe to end, surfaces open action items, and writes the session's learnings back to memory and the KB so the workspace grows. Triggers on '/73', 'signing off', 'wrap up the session', 'end of session', 'that's a wrap'.
---

# /73 - Sign-off

The user is signing off (`/73` - ham radio for "best regards / signing off"). Run a three-part end-of-session check and reply with the results.

This is the ritual that makes the workspace **grow**. "Corrections become memory, finished work accumulates in the knowledge base" only happens if something writes it back at the end of a session - this is that something. The same is true of the third growth path: repeated work only becomes a skill if a ritual *notices* the repetition. `/73` is where all of it fires. Don't skip the writing.

## The check

1. **Safe to end?** - Anything mid-flight: uncommitted edits, running processes, half-finished tool calls, undeployed changes?

2. **Open action items?** - What's left for the user, or for you to follow up on next session?

3. **Documented everything?** - Memory updated, KB notes written, task-tracker cards created/updated, any other persistence the session warrants? **Don't just check - actually do the documentation.** Scan the thread for durable value (decisions, learnings, project-state changes, new context, surprising findings) and write each to its correct home *before* you answer:
   - **Cross-cutting behavioral correction** → inline in MEMORY.md, or a `claude-memory/feedback_*.md` only if it genuinely cross-cuts most sessions.
   - **Project state / decision** → `projects/<project>/overview.md`.
   - **Domain learning** → the relevant book chapter.
   - **Follow-up task** → your PM tool (Trello / Linear / Jira / GitHub Issues / whatever you configured).

   Follow the two standing rules while you write: **no standalone feedback files** (inline it next to what it modifies), and **MEMORY.md signal density** (don't add a line unless it changes behavior in ~1-in-5 sessions).

4. **Repeated work worth encoding?** - Did a multi-step workflow recur this session, or match a candidate already logged in `project_skill_backlog.md`? This is where the 3x rule actually fires (a backlog nobody checks is dead; this ritual is the check):
   - **Done by hand 3+ times now** → *offer* to encode it as a skill before ending. If they say yes, co-author `~/.claude/skills/{name}/SKILL.md` (a trigger-packed `description`, a "first action: load context" line pointing at the real project file, the steps named inline), add a one-line entry to `claude-skills/_index.md`, and run it once if it's useful to watch it fire.
   - **1st or 2nd time** → add it, or tick it, in `project_skill_backlog.md` with today's date. Don't build yet.

   Never force a skill into existence - an empty backlog is the correct, honest state. Just make sure the repetition got *noticed* and landed somewhere.

Answer concisely: a short bulleted answer per question - **including what you just documented and where** - then a clear "yes, safe to end" / "wait, do X first" verdict.
