# Changelog

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
