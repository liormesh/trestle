---
name: 73
description: Sign-off — end-of-session checklist. Confirms it's safe to end, surfaces open action items, and writes the session's learnings back to memory and the KB so the workspace grows. Triggers on '/73', 'signing off', 'wrap up the session', 'end of session', 'that's a wrap'.
---

# /73 — Sign-off

The user is signing off (`/73` — ham radio for "best regards / signing off"). Run a three-part end-of-session check and reply with the results.

This is the ritual that makes the workspace **grow**. "Corrections become memory, finished work accumulates in the knowledge base" only happens if something writes it back at the end of a session — this is that something. Don't skip the writing.

## The check

1. **Safe to end?** — Anything mid-flight: uncommitted edits, running processes, half-finished tool calls, undeployed changes?

2. **Open action items?** — What's left for the user, or for you to follow up on next session?

3. **Documented everything?** — Memory updated, KB notes written, task-tracker cards created/updated, any other persistence the session warrants? **Don't just check — actually do the documentation.** Scan the thread for durable value (decisions, learnings, project-state changes, new context, surprising findings) and write each to its correct home *before* you answer:
   - **Cross-cutting behavioral correction** → inline in MEMORY.md, or a `claude-memory/feedback_*.md` only if it genuinely cross-cuts most sessions.
   - **Project state / decision** → `projects/<project>/overview.md`.
   - **Domain learning** → the relevant book chapter.
   - **Follow-up task** → your PM tool (Trello / Linear / Jira / GitHub Issues / whatever you configured).

   Follow the two standing rules while you write: **no standalone feedback files** (inline it next to what it modifies), and **MEMORY.md signal density** (don't add a line unless it changes behavior in ~1-in-5 sessions).

Answer concisely: a short bulleted answer per question — **including what you just documented and where** — then a clear "yes, safe to end" / "wait, do X first" verdict.
