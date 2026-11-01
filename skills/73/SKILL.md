---
name: 73
description: Sign-off - end-of-session checklist. Runs the workspace health check, confirms it's safe to end, surfaces open action items, and writes the session's learnings back to memory and the KB so the workspace grows. Triggers on '/73', 'signing off', 'wrap up the session', 'end of session', 'that's a wrap'.
model: sonnet
---

# /73 - Sign-off

The user is signing off (`/73` - ham radio for "best regards / signing off"). Run the end-of-session check and reply with the results.

This is the ritual that makes the workspace **grow** and keeps it **healthy**. Corrections become memory, finished work accumulates in the knowledge base, repeated work becomes a skill - but only because something writes it back at the end of a session. And the workspace's upkeep (broken links, stale projects, the memory sweep) only happens because something checks for it here. This is that something. Don't skip the writing.

## Token discipline (read this first)

`/73` fires when the session's context is at its fullest, so **every tool call re-sends the whole conversation**. In real use, a sign-off that made a separate call per file cost millions of tokens - nearly all of it the same context re-sent. Round-trips are the cost, not the thinking. (That's also why this skill is pinned to a smaller model: the sign-off is bookkeeping, not reasoning.)

**Target: 3 tool calls or fewer.**
- **One shell call for step 0** - the health check plus any `git status` you need, chained with `;`.
- **One shell call for all of step 3's writes** - a sequence of heredocs / appends in a single call. Never one edit call per file.
- **Don't re-read what's already in context.** The session transcript is the input for step 3 - you already have it.
- **Don't verify your own writes.** A heredoc that didn't error, wrote.

If a step genuinely needs nothing done, do nothing - don't spend a call proving it.

## Step 0 - Health check (one shell call, first)

```bash
node ~/.claude/trestle/kb-check.mjs
```

(`--hours N` widens the window for a long session. If the file doesn't exist, the workspace predates Trestle v1.8 - say so, recommend re-running the installer and `/onboard` → (d), and continue with steps 1-4.)

**Early exit:** if the output says `SCOPE: 0 md files touched`, nothing WARNs, and nothing in this session's thread is worth documenting, the session was a no-op: answer in one turn - "nothing touched, nothing to write, safe to end" - and stop.

Otherwise every `WARN` is a defect from *this* session. Fix it in step 3's batched write - don't just list it:
- `LINKS` → repair each broken link to the real filename (markdown links are relative to the file's folder; `[[wikilinks]]` resolve by filename).
- `SECRETS` → move the value to `_private/credentials.md`, leave a pointer. If the file was already committed, tell the user plainly: **the key is in git history - rotate it.**
- `FRONTMATTER` → `name:` equal to the filename, a `description:`, a type; rename `_` filenames to `<type>-<slug>.md`.
- `MEMORY-INDEX` → add a one-line pointer to MEMORY.md (behavioral hook) or MEMORY-extended.md (detail). An unindexed memory file can never be recalled.
- `PARA-STATE` → `state:` belongs only on `projects/<p>/overview.md`, values `project | area | archive | icebox`, with `state_changed:`.
- `MEMORY-SIZE` → move lines to MEMORY-extended.md or the project's handoff doc.
- `SYNC` → mention it in the verdict (uncommitted or unpushed work isn't backed up).
- `RATCHET` → a vault-wide count rose. If this session caused it, fix it now; otherwise list it as an action item.

Not fix-now, but action items for step 2: `SWEEP: OVERDUE` ("run the memory sweep next session" - see `feedback-memory-decay.md`), `STALE` projects (name the next finish line or change `state:`), `UPGRADE` (re-run the installer, then `/onboard` → (d)).

## Step 1 - Safe to end?

Anything mid-flight: uncommitted edits, running processes, half-finished tool calls, undeployed changes? Include the `SYNC` line. Answer from what step 0 already returned.

## Step 2 - Open action items?

What's left for the user, or for you to follow up on next session? Include the not-fix-now items from step 0.

## Step 3 - Documented everything? (one batched shell call)

Memory updated, KB notes written, task-tracker cards created/updated, any other persistence the session warrants. **Don't just check - actually do the documentation.** Scan the thread for durable value (decisions, learnings, project-state changes, new context, surprising findings) and route each to its home:

- **Live project status** (what moved, what's next, what's blocked) → rewrite `pm/handoff/<project>-resume-prompt.md` in place, and append 2-4 dated lines to `pm/handoff/<project>-handoff-log.md`. **Not MEMORY.md** - live status in the always-loaded index goes stale and gets duplicated.
- **Project state changed** (finished a push, parked it) → `state:` + `state_changed:` in `projects/<project>/overview.md`. A stable decision about the project → that overview's Key Decisions.
- **Cross-cutting behavioral correction** → inline in MEMORY.md, or a `claude-memory/feedback-<slug>.md` only if it genuinely cross-cuts most sessions (then add its pointer line to MEMORY.md).
- **Domain learning** → the relevant book chapter.
- **Follow-up task** → the user's PM tool (Trello / Linear / Jira / GitHub Issues / whatever they configured). Tool calls to a PM tool can't batch into the shell call; make them only if the session warrants a card.
- **The memory sweep ran this session** → append `<ISO-UTC> memory-sweep <note>` to `_analytics/usage.log`, so the health check knows.

Standing rules while writing: **no standalone feedback files** (inline it next to what it modifies), and **MEMORY.md signal density** (no line unless it changes behavior in ~1-in-5 sessions; no live status in the index).

Decide every write first, then emit them in **one** shell call, plus the step-0 WARN fixes. Then append `<ISO-UTC> 73 <short note>` to `_analytics/usage.log` in the same call.

## Step 4 - Repeated work worth a skill?

Did a multi-step workflow recur this session, or match a candidate in `project-skill-backlog.md`? This is where the 3x rule actually fires - a backlog nobody checks is dead; this ritual is the check:
- **Done by hand 3+ times now** → *offer* to encode it as a skill before ending (check `claude-skills/_index.md` first - maybe an existing skill just needs a new mode). If they say yes, co-author `~/.claude/skills/{name}/SKILL.md` (a trigger-packed `description`, a "first action: load context" line pointing at the real project file, the steps named inline), add a one-line entry to `claude-skills/_index.md`, and run it once if it's useful to watch it fire.
- **1st or 2nd time** → add it, or tick it, in `project-skill-backlog.md` with today's date (fold into step 3's batched write). Don't build yet.

Never force a skill into existence - an empty backlog is the correct, honest state.

## Answer format

A short bulleted answer per step - the health check's one-line results, what was just documented and where - then a clear "yes, safe to end" / "wait, do X first" verdict.
