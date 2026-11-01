# Changelog

## v1.8.0 - 2026-11-01

**How it stays healthy.** v1.8 catches Trestle up with three months of running the framework for real, and closes every open item from the July 2026 review. The headline is a lesson about maintenance: rules written in memory get forgotten; rituals hold; **checks that fail hold best**. So this release adds checks - two guardrail hooks, a health check `/73` runs at every sign-off, and a ratchet - and finally gives existing installs an upgrade path.

### Added

- **Guardrail hooks** (`~/.claude/trestle/`, registered in `settings.json` by `/onboard`):
  - **Secret guard** (`PreToolUse`) - blocks a write into the KB, memory or skills that contains a credential-shaped value (Anthropic / OpenAI / GitHub / Slack / AWS / Google / Stripe keys, JWTs, private keys, password-bearing connection strings). `_private/` is exempt. **Why:** a key that gets committed stays in git history even after you delete or gitignore it - the only real fix is rotating it. Blocking it at write time is cheap; cleaning up after is not.
  - **Link guard** (`PostToolUse`) - after a markdown write, reports links in the text just written that point at nothing, with a did-you-mean. **Why:** a broken pointer is a silent dead end - nothing fails, Claude just never finds the file.
- **Workspace health check** - `kb-check.mjs`, run by `/73` as step 0 (and by you, any time). Checks the files touched this session for broken links, secrets, memory files with bad frontmatter or no index line, misplaced `state:` fields; checks MEMORY.md for size and dated (volatile) lines; flags projects stalled 45+ days, an overdue memory sweep, uncommitted/unpushed work, and a framework upgrade waiting. `--usage 30` reports skill usage from the analytics log.
- **The ratchet** - `_analytics/baseline.json` records vault-wide problem counts (broken links, secrets, unindexed memory, ...). They may fall (the baseline tightens automatically), never rise. Pre-existing problems are recorded on the first run, not blamed on the session.
- **Project state (`state:`)** - every `projects/<p>/overview.md` now carries `state: project | area | archive | icebox` + `state_changed:`, and only the overview carries it. "What's in flight?" becomes a grep; a `project` that hasn't moved in 45 days gets flagged, because a project is supposed to finish.
- **Handoff docs** - `pm/handoff/<project>-resume-prompt.md` (living: finish line, in flight, next step - what `/cq` reads first) and `<project>-handoff-log.md` (append-only, written by `/73`). Live project status finally has a home that isn't MEMORY.md.
- **Upgrade path - `/onboard` option (d) "update the framework".** Re-run the installer, then `/onboard` → (d): renames legacy files and fixes every reference, refreshes shipped rule files you never edited (silently), asks per file before touching ones you did (replace / keep / merge), adds what's new (handoff docs, project states, hooks, `.gitignore` lines), refreshes the managed block of `CLAUDE.md`, and never rewrites your own content.
- **`dev/test-tools.sh`** - tests the hooks and the health check against a fixture workspace with planted defects (29 checks); `dev/test-fresh-user.sh` now also tests the upgrade path (18 more).

### Changed

- **The memory-size rule now leads with volatility.** Soft cap moves from ~60 to ~100 lines, and the primary rule becomes: **no live status in the always-loaded index** - "launching Thursday" lives in the handoff doc, MEMORY.md points there. **Why:** volatile lines go stale, force constant edits to the one file loaded into every conversation (each edit defeats prompt caching), and end up disagreeing with the project doc. This was the most valuable lesson missing from v1.7.
- **`/73` is cheaper and does more.** Runs the health check first and fixes every WARN before signing off; writes live status to the handoff doc instead of memory; targets **3 tool calls or fewer** (one sign-off was measured at millions of tokens because each call re-sends the whole session) and is pinned to a smaller model (`model: sonnet`) - the sign-off is bookkeeping, not reasoning.
- **`/cq` reads the handoff doc first**, then the overview; reports the project's state and the current finish line; flags a stalled project.
- **The memory sweep is triggered by `/73`, not a calendar.** `SWEEP: OVERDUE` after 30 days; a finished sweep logs a `memory-sweep` line. **Why:** in real use, everything scheduled monthly stopped happening; everything attached to a ritual kept running.
- **Memory files follow one convention:** `<type>-<slug>.md`, kebab-case, `name:` equal to the filename, a pointer line in MEMORY.md. The scaffolded files used to break their own rule (`feedback_health_check.md`, `name: MEMORY.md size & density rule`). Frontmatter follows the shape your Claude Code version writes (`metadata: type:` in current versions); the health check accepts both shapes.
- **Shipped files are real templates** (`skills/onboard/templates/`) instead of text inlined in the 750-line skill - copied verbatim and version-stamped, which is what makes the upgrade diff possible.
- **`CLAUDE.md` rules sit between `trestle:rules` markers** so upgrades refresh them without touching anything you add outside.
- **The installer updates instead of skipping.** An installed skill that differs from the new version is backed up to `~/.claude/trestle/backups/<timestamp>/` and replaced; unchanged skills are left alone. It also installs the tools and checks for Node.js 18+.
- **Analytics have one strict format:** `<ISO-UTC> <skill> <note>`. The health check flags malformed lines.
- **`.gitignore` keeps the KB text-only:** adds `node_modules/`, `.env*` and large media/archive types. **Why:** a single committed `node_modules` once made up two thirds of a real vault - and deleting it later doesn't shrink git history.
- **`credentials.md` says what happens after a leak:** a committed key is exposed until rotated; production keys belong in a real secret manager.

### Removed

- **`_analytics/weekly-summary.md`** - a manual consolidation file that never got filled in real use. The sweep reads the log directly (`kb-check.mjs --usage 30`). Option (d) offers to delete it.

### Requirements

- **Node.js 18+** is now needed for the hooks and the health check (plain `node`, no packages). Without it the hooks fail open and `/73` skips step 0 - everything else works as before.

### Migration (existing workspaces)

1. Re-run the install one-liner (it updates the skills and installs the tools; your old skills are backed up).
2. Open Claude Code from your home directory, run `/onboard`, pick **(d)**.

That's it - (d) handles renames, rule refreshes, project states, handoff docs and hooks, asks before touching anything you edited, and finishes by running the health check once so the ratchet records your starting point.

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
