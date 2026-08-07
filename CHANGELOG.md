# Changelog

## v1.7.0 - 2026-08-07

A new starter skill with its own book, plus two fixes that strengthen the **Agents leg** and make the permission story honest. (This release also sweeps the whole repo to hyphens - no em/en dashes anywhere.)

### Added

- **`/visualize` skill - turn a plan, report, or dataset into a self-contained HTML or PDF artifact** (one file, opens offline, no build step). On-demand, not a default behavior. Installed by the one-liner alongside `/onboard`, `/cq`, and `/73`.
- **`dataviz` book - the framework's first shipped book, and the worked example of the skill + book pattern.** `/visualize` ships paired with a `books/dataviz/` book (`_toc.md` + five chapters: when-and-format, self-contained HTML, charts and data, PDF output, and a `ch05-gotchas.md` learning-loop chapter). `/onboard` copies it into the user's KB `books/`, and `/visualize` loads its chapters on demand rather than carrying the craft in its own body. It's the concrete demonstration that a skill's depth lives in a book (cold context), not in the skill file. **Why:** the scaffold previously shipped `books/README.md` but no actual book, so the strongest Context-leg pattern (a skill reading a two-level-indexed book on demand, the book compounding via post-task write-back) had no live example on day one.

### Changed

- **`/73` now runs the 3x-rule at sign-off (Agents-leg growth).** The sign-off check gained a fourth item: did a multi-step workflow recur this session (or match a `project_skill_backlog.md` candidate)? If it's now been done by hand 3+ times, `/73` *offers* to encode it as a skill on the spot; otherwise it logs/ticks the candidate with a date. Never forces a skill - an empty backlog is still the honest state. **Why:** the backlog and the 3x rule only work if a ritual checks them. Everything scheduled as a calendar obligation drifted in real use; everything attached to a ritual held. Skill-creation now rides the ritual that already fires. (Mirrors how OpenAI's Codex app auto-mints skills from repeated work.)
- **Permission defaults reframed as a seatbelt, not a security boundary.** Removed the `DROP TABLE` / `DROP DATABASE` deny entries (pure false comfort - SQL arrives inside `psql -c` or an MCP call and never matches a `Bash(...)` pattern). The README and the onboard settings step now say plainly that the deny list is a coarse backstop, that real control is the permission *mode* (plus an optional `PreToolUse` hook), and that `_private/credentials.md` is a convenience with a real blast radius. **Why:** the old "safe-by-default permissions" wording over-promised - a bigger foot-gun for a general (and especially a data-sensitive) audience than an honest "here's what this does and doesn't cover."

### Migration (existing workspaces)

No action required. Re-running `/onboard` (options a/b) does not yet refresh shipped rule files - the framework-rules upgrade path remains a separate backlog item. To adopt now: pull the updated `/73` skill, and delete the two `DROP *` lines from your `settings.json` deny list if present.

## v1.6.0 - 2026-07-28

Close the cold-start gap on the **Agents leg**: onboarding now ends by building the user's *first real skill* with them, from a task they already do - so they leave with something valuable in the leg, not an empty catalog and a rule that says "wait."

### Added

- **`/onboard` now has a guided first-skill step (Step 6), run after the workspace is scaffolded** so the new skill can point at the project files just written. It's framed deliberately as *importing a habit you already have*, not inventing one:
  - **If the user names a repeated task** (a weekly report, a pre-ship check, a doc they keep writing), Claude co-authors the `SKILL.md` with them - frontmatter with real trigger phrases, a first-action context load wired to their actual `projects/{name}/overview.md`, tools declared inline (least-privilege; secrets routed to `_private/credentials.md`) - registers it in `_index.md`, and **offers to run it once** so they watch their own skill fire.
  - **If they draw a blank**, nothing is built. The step converts the empty Agents leg into a *taught principle*: skills come from real work, the backlog (`project_skill_backlog.md`) is already there to catch candidates, and `/73` will nudge at sign-off. No placeholder row is written - an empty backlog is the correct state.

### Why

A fresh install scaffolded the Context leg richly but left the value-bearing Agents leg nearly empty, and the 3x-rule (correctly) told brand-new users to *wait* before building skills - a cold-start paradox in a tool that sells "up to speed quicker." The fix respects the rule rather than bending it: a task done every week isn't preemptive, it's a habit worth encoding. Either outcome is a win - the user walks away having watched their own skill run on their own data, or understanding precisely what earns the next one. (Pairs with the reference stool as the two halves of "what does a full leg look like" - an example to study, and one of your own to keep.)

### Migration (existing workspaces)

No action required. To get the guided step on an existing workspace, re-run `/onboard` (options a/b never overwrite your content) - or just build a skill by hand from your backlog; the mechanics are the same.

## v1.5.0 - 2026-07-06

Ship the **first-run check** - a one-line proof that a fresh install actually works.

### Added

- **`_first-run-check.md` now scaffolds with every workspace.** It's a cold KB file holding a
  distinctive magic word. In a fresh Claude Code session you ask *"Read _first-run-check.md and tell me
  the magic word"*; a correct reply proves the Brain leg end to end - the engine runs **and** it can read
  your files on demand (a first taste of cold context). The word lives only in the file (never in hot
  memory), so answering it requires actually opening the file.

### Why

The workshop's first hands-on checkpoint has everyone read a "checkpoint file" back - but no install ever
shipped one, so the check had no target. Scaffolding `_first-run-check.md` makes that checkpoint real out
of the box, and gives solo users the same fast "is it alive?" self-test. (Also corrected a stale
"auto-generated" note on `weekly-summary.md` in the onboard tree preview - it's consolidated by hand on the
memory sweep, matching the file's own content.)

## v1.4.0 - 2026-07-04

Ship the **Agents leg with something in it**, and turn the "it grows the more you use it" promise from a claim into shipped rituals. Until now a fresh install scaffolded the Context leg well but left the Agents catalog empty and the growth loop to chance.

### Added

- **Two starter session-ritual skills ship with every install**, alongside `/onboard`:
  - **`/cq <project>`** - *calling a project.* Tunes a session into one project's full context (resume/handoff doc, overview, gotchas, deploy rules) and runs the health check before you start. The Context leg as a one-command ritual. Read-and-orient only.
  - **`/73`** - *sign-off.* End-of-session checklist that confirms it's safe to end, surfaces open action items, and **writes the session's learnings back** to memory and the KB (following the no-standalone-feedback and signal-density rules). This is the ritual that actually runs the growth loop - corrections become memory and finished work accumulates on purpose, not by luck.
- **`feedback_memory_decay.md`** now ships with every install - a periodic active / archive / promote sweep so the hot layer (MEMORY.md) stays dense as it accumulates.
- **`project_skill_backlog.md`** now ships with every install - the 3x-skill rule made auditable. Recurring manual workflows get logged with dated evidence before they earn a skill.
- **`_index.md` now ships populated** with the three starter skills instead of an empty stub, so the "check the catalog first" rule has real entries from conversation #1.

### Changed

- **Analytics wording corrected.** `weekly-summary.md` previously implied a summary would "appear" automatically - there is no background job. It's now honestly framed as a manual consolidation target you fill on your memory-decay sweep.
- **Installers copy all starter skills**, not just `/onboard` (bash loop + PowerShell `foreach`).
- **MEMORY.md and CLAUDE.md templates** now reference the session rituals, the memory-decay sweep, and the skill backlog.
- **README** documents the three shipped skills, the growth-loop rituals, and the corrected analytics story.

### Migration (existing workspaces)

No action required - new files only affect fresh installs. To retrofit an existing workspace: re-run `/onboard` (options b/c never overwrite your content), or copy `skills/cq/` + `skills/73/` into `~/.claude/skills/`, add `feedback_memory_decay.md` + `project_skill_backlog.md` to your memory dir, and list `/cq` + `/73` in your `_index.md`.

### Why

The workshop this tool supports teaches Brain / Agents / Context and sells the *slope* - "it grows the more you sit on it." A fresh install told that story but didn't ship the machinery that runs it: the Agents catalog was empty, nothing wrote learnings back at session end, and there was no home for skill candidates or a decay cadence. `/cq` + `/73` + the two new files close that gap, so a new user *feels* the loop from day one instead of being asked to take it on faith.

## v1.3.0 - 2026-06-07

Align the framework's language with the current mental model: **Brain / Agents / Context** (the three-legged stool). Previously framed as "knowledge base + memory + skills."

### Changed

- **The model is now Brain / Agents / Context.** The Brain is Claude Code (the interchangeable model you talk to). Agents are skills plus the tools to run them. Context merges the knowledge base (cold, on-demand) and memory (hot, always-loaded). The README, onboard overview/welcome, and the generated vault README now teach this framing.
- **Framing only - no scaffolding changes.** The folder structure is unchanged; it already produces the Context (knowledge-base + memory) and Agents (skills) legs. Existing workspaces are unaffected.

## v1.2.0 - 2026-05-26

Align scaffolded defaults with current framework practice. The previous defaults taught new installs patterns that the framework had since outgrown.

### Breaking (for new installs only - existing workspaces unaffected)

- **Removed `feedback_preferences.md` scaffolding.** Q7 pet-peeves now land inline in MEMORY.md under a "Preferences" section instead of being written to a standalone memory file. Shipping a standalone `feedback_preferences.md` directly contradicted the no-standalone-feedback rule and taught every fresh Claude session that creating new feedback files was fine.
- **MEMORY.md size rule rewritten.** The old "under 50 lines" cap was a proxy for density that aged poorly. New rule: every line must affect behavior in roughly 1-in-5 conversations, with a ~60-line soft cap as a smell test. Updated `feedback_memory_size.md` ships with the new framing.

### Added

- **`feedback_no_standalone_feedback.md`** now ships with every install - explicit cross-cutting rule that new feedback goes inline in the relevant KB file (skill, book chapter, project overview), and only genuinely cross-cutting rules belong in `claude-memory/`.
- **`claude-skills/_index.md` catalog stub.** `~/.claude/skills/` is now seeded with an `_index.md` so the "don't create a skill until you've done it 3 times - check existing skills first" rule has a place to actually check.
- **MEMORY.md template now includes a "Behavioral Rules" section** with pointers to the three shipped feedback files plus the 3x-skill-rule and analytics log convention, so the rules are visible from conversation #1.

### Changed

- **CLAUDE.md template restructured** into "Knowledge System" + "Rules" sections matching production usage. Calls out signal-density, no-standalone-feedback, the 3x-skill rule, single-source-of-truth, and the analytics convention as the load-bearing rules.
- **README "Framework Rules" section** updated to describe density-based MEMORY sizing and the `_index.md` skill-check workflow.
- **Step 6 summary recap** now lists the three feedback files actually scaffolded (no more `feedback_preferences.md`).

### Migration (existing workspaces)

No action required - these changes only affect what `/onboard` scaffolds on a fresh install. If you want to retrofit:

1. Delete `feedback_preferences.md` and move its content as bullets into MEMORY.md under "Preferences".
2. Replace `feedback_memory_size.md` with the v1.2.0 content (see `skills/onboard/SKILL.md`).
3. Add `feedback_no_standalone_feedback.md` from the same source.
4. Create `~/.claude/skills/_index.md` if missing.

### Why

The framework has been live long enough that production usage has drifted from the original onboarding defaults. Two of the shipped files (`feedback_preferences.md`, old `feedback_memory_size.md`) actively contradicted rules the framework had since adopted. Fixing the defaults so new users start in a state consistent with how the framework is actually used.

---

## v1.1.0

Add framework guardrails from production use.

## v1.0.0

Initial release - `/onboard` skill, install script, README.
