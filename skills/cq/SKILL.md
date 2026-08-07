---
name: cq
description: Calling a project - tune this session into one project's full context before you start working. Reads the project's overview, gotchas, and rules, then reports what frequency you're on. Triggers on '/cq <project>', 'tune into <project>', 'load <project> context', 'call up <project>', 'work on <project>'.
argument-hint: [project name]
---

# /cq - Calling a project

`/cq` is the radio opening call ("seeking contact") - the user wants to tune this session into a specific project's frequency before you work. The project is: **$ARGUMENTS**

Load that project's context now, then confirm you're tuned in. This is the **Context leg** in action: pull the right context at the right moment, instead of re-briefing from scratch every session.

## Steps

1. **Resolve the project.** Map `$ARGUMENTS` to a project in the knowledge base - check MEMORY.md's active-projects list and the `projects/` folder. If ambiguous or empty, list the closest matches and ask which one. Don't guess.

2. **Read its context, in this order (skip any that don't exist):**
   - Handoff / resume prompt, if the project keeps one (e.g. `projects/<project>/resume-prompt.md` or a `handoff/` doc).
   - Project overview: `projects/<project>/overview.md`.
   - Any project-specific gotchas, deploy notes, or state files the overview or MEMORY points to (deploy target, credential locations, known footguns).

3. **Surface the project's own rules** - anything in MEMORY or the project doc that changes how you should behave on *this* project (where it deploys, which credential to use, conventions to respect).

4. **Run a health check if this is a coding session** (per the health-check rule) - run the command in the project's `## Health Check` section before writing code. Skip for read-only work.

5. **Report back, briefly:**
   - What frequency we're on - project + one-line current state.
   - Live action items / open threads.
   - The gotchas you'll respect this session.
   - What you read to get there.
   Then ask what we're doing.

This is **read-and-orient only** - don't change anything until the user says what the task is.
