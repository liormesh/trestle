# Changelog

## v1.4.0 — 2026-07-04

Ship the **Agents leg with something in it**, and turn the "it grows the more you use it" promise from a claim into shipped rituals. Until now a fresh install scaffolded the Context leg well but left the Agents catalog empty and the growth loop to chance.

### Added

- **Two starter session-ritual skills ship with every install**, alongside `/onboard`:
  - **`/cq <project>`** — *calling a project.* Tunes a session into one project's full context (resume/handoff doc, overview, gotchas, deploy rules) and runs the health check before you start. The Context leg as a one-command ritual. Read-and-orient only.
  - **`/73`** — *sign-off.* End-of-session checklist that confirms it's safe to end, surfaces open action items, and **writes the session's learnings back** to memory and the KB (following the no-standalone-feedback and signal-density rules). This is the ritual that actually runs the growth loop — corrections become memory and finished work accumulates on purpose, not by luck.
- **`feedback_memory_decay.md`** now ships with every install — a periodic active / archive / promote sweep so the hot layer (MEMORY.md) stays dense as it accumulates.
- **`project_skill_backlog.md`** now ships with every install — the 3x-skill rule made auditable. Recurring manual workflows get logged with dated evidence before they earn a skill.
- **`_index.md` now ships populated** with the three starter skills instead of an empty stub, so the "check the catalog first" rule has real entries from conversation #1.

### Changed

- **Analytics wording corrected.** `weekly-summary.md` previously implied a summary would "appear" automatically — there is no background job. It's now honestly framed as a manual consolidation target you fill on your memory-decay sweep.
- **Installers copy all starter skills**, not just `/onboard` (bash loop + PowerShell `foreach`).
- **MEMORY.md and CLAUDE.md templates** now reference the session rituals, the memory-decay sweep, and the skill backlog.
- **README** documents the three shipped skills, the growth-loop rituals, and the corrected analytics story.

### Migration (existing workspaces)

No action required — new files only affect fresh installs. To retrofit an existing workspace: re-run `/onboard` (options b/c never overwrite your content), or copy `skills/cq/` + `skills/73/` into `~/.claude/skills/`, add `feedback_memory_decay.md` + `project_skill_backlog.md` to your memory dir, and list `/cq` + `/73` in your `_index.md`.

### Why

The workshop this tool supports teaches Brain / Agents / Context and sells the *slope* — "it grows the more you sit on it." A fresh install told that story but didn't ship the machinery that runs it: the Agents catalog was empty, nothing wrote learnings back at session end, and there was no home for skill candidates or a decay cadence. `/cq` + `/73` + the two new files close that gap, so a new user *feels* the loop from day one instead of being asked to take it on faith.

## v1.3.0 — 2026-06-07

Align the framework's language with the current mental model: **Brain / Agents / Context** (the three-legged stool). Previously framed as "knowledge base + memory + skills."

### Changed

- **The model is now Brain / Agents / Context.** The Brain is Claude Code (the interchangeable model you talk to). Agents are skills plus the tools to run them. Context merges the knowledge base (cold, on-demand) and memory (hot, always-loaded). The README, onboard overview/welcome, and the generated vault README now teach this framing.
- **Framing only — no scaffolding changes.** The folder structure is unchanged; it already produces the Context (knowledge-base + memory) and Agents (skills) legs. Existing workspaces are unaffected.

## v1.2.0 — 2026-05-26

Align scaffolded defaults with current framework practice. The previous defaults taught new installs patterns that the framework had since outgrown.

### Breaking (for new installs only — existing workspaces unaffected)

- **Removed `feedback_preferences.md` scaffolding.** Q7 pet-peeves now land inline in MEMORY.md under a "Preferences" section instead of being written to a standalone memory file. Shipping a standalone `feedback_preferences.md` directly contradicted the no-standalone-feedback rule and taught every fresh Claude session that creating new feedback files was fine.
- **MEMORY.md size rule rewritten.** The old "under 50 lines" cap was a proxy for density that aged poorly. New rule: every line must affect behavior in roughly 1-in-5 conversations, with a ~60-line soft cap as a smell test. Updated `feedback_memory_size.md` ships with the new framing.

### Added

- **`feedback_no_standalone_feedback.md`** now ships with every install — explicit cross-cutting rule that new feedback goes inline in the relevant KB file (skill, book chapter, project overview), and only genuinely cross-cutting rules belong in `claude-memory/`.
- **`claude-skills/_index.md` catalog stub.** `~/.claude/skills/` is now seeded with an `_index.md` so the "don't create a skill until you've done it 3 times — check existing skills first" rule has a place to actually check.
- **MEMORY.md template now includes a "Behavioral Rules" section** with pointers to the three shipped feedback files plus the 3x-skill-rule and analytics log convention, so the rules are visible from conversation #1.

### Changed

- **CLAUDE.md template restructured** into "Knowledge System" + "Rules" sections matching production usage. Calls out signal-density, no-standalone-feedback, the 3x-skill rule, single-source-of-truth, and the analytics convention as the load-bearing rules.
- **README "Framework Rules" section** updated to describe density-based MEMORY sizing and the `_index.md` skill-check workflow.
- **Step 6 summary recap** now lists the three feedback files actually scaffolded (no more `feedback_preferences.md`).

### Migration (existing workspaces)

No action required — these changes only affect what `/onboard` scaffolds on a fresh install. If you want to retrofit:

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

Initial release — `/onboard` skill, install script, README.
