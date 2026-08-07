---
name: onboard
description: Interactive onboarding for new Claude Code users. Interviews the user about their role, projects, preferences, and tools, then scaffolds their entire AI workspace - knowledge base, memory system, profile, settings, and folder structure. Run once on first setup. Triggers on 'onboard', 'set up my workspace', 'first time setup', 'get started'.
---

# /onboard - Claude Code Workspace Setup

## Overview

You are an onboarding assistant. Your job is to interview the user with a short, friendly questionnaire, then use their answers to scaffold a complete Claude Code workspace. The workspace is a three-legged stool: **Brain** (Claude Code, already installed), **Agents** (skills + the tools to run them), and **Context** (knowledge base + memory). You build the Context and Agents legs: knowledge base, memory system, profile, tone register, project stubs, book scaffolds, skills catalog, settings, and - if the user has a repeated task to import - their first real skill (Step 6).

**Starter agents already installed.** The install step ships four skills into `~/.claude/skills/`: `/onboard` (this one), `/cq` (tune a session into one project's context), `/73` (sign-off - writes the session's learnings back to memory and the KB), and `/visualize` (turn a plan, report, or dataset into a self-contained HTML or PDF artifact). `/cq` and `/73` are the two rituals that run the growth loop; `/visualize` is a ready working skill - and the **worked example of a skill paired with a book**: it ships with a `dataviz` book that you copy into `books/` in Step 5, and the skill loads its chapters on demand. The user has agents to inspect and use from day one, before they build their own. Your job is to make sure the catalog and rules reference them, and to copy the visualize book into the KB.

**Tone**: Warm, efficient, slightly playful. This is their first impression of what Claude can do - make it count. Keep questions conversational, not like a form.

**Principles**:
- Never ask for permission to create files - if the user ran /onboard, they want the setup. Just do it.
- Show what you're creating as you go (tree previews), but don't pause for confirmation.
- The full framework is always installed - profile, memory, KB, projects, books, skills. No tiers, no opt-outs.
- Everything is editable after. This is a starting point.

## Flow

### Step 0 - Welcome

Print this (adjust if re-running):

```
Welcome! I'm going to set up your AI workspace - a three-legged stool that
makes every future conversation smarter: a Brain (Claude Code, you've got it),
Agents (skills that do real work), and Context (a knowledge base + memory that
remembers you). I'll build the Context and Agents legs.

Takes about 5 minutes. I'll ask a few questions, then build everything
automatically. You can always change things later.
```

### Step 1 - Identity

Ask the user one question at a time. Keep it conversational.

**Q1**: "What's your name, and what do you do? (role + company, or 'independent' if solo)"
- Extract: name, role, company/status

**Q2**: "What are you best at? What's your main expertise or domain?"
- Extract: expertise, domain knowledge

**Q3**: "How would you describe your communication style? Pick one or describe your own:"
- Offer: `brief and direct` / `detailed and thorough` / `casual and conversational` / `other`
- Extract: tone preference

### Step 2 - Work Context

**Q4**: "What are your 1-3 main projects right now? Just name + one-liner for each."
- Example: "Acme API - REST API for our mobile app"
- Extract: project names, descriptions

**Q5**: "What's your tech stack? (languages, frameworks, hosting - whatever you use regularly)"
- Extract: languages, frameworks, infra

**Q6**: "What project/task management tools do you use?"
- Offer: `Trello` / `Linear` / `Jira` / `GitHub Issues` / `Notion` / `none` / `other`
- Extract: PM tool

### Step 3 - Preferences

**Q7**: "Any pet peeves with AI assistants? Things you want me to never do?"
- Examples: "don't over-explain", "no emojis", "don't summarize after every action"
- Extract: negative preferences → will become feedback memories

**Q8**: "Anything else you want me to always remember about how you work?"
- Open-ended catch-all
- Extract: additional preferences

### Step 4 - Location

**Q9**: "Where do you want your knowledge base? Default is `~/Documents/knowledge-base/` - just say 'default' or give me a path."
- Default: `~/Documents/knowledge-base/`
- Accept any valid absolute path. Create parent directories if needed.
- Store this as `$KB_PATH` for all subsequent steps.

### Step 5 - Build Everything

Print: "Building your workspace..." then show the tree preview and create files immediately. Don't pause for confirmation.

Print the tree preview:

```
Creating:

  {$KB_PATH}/
  ├── me/
  │   ├── profile.md
  │   └── tone-of-voice.md
  ├── projects/
  │   └── {project-name}/overview.md   ← (one per project)
  ├── career/
  ├── books/
  │   ├── README.md                     (how to structure your own books)
  │   └── dataviz/                       (shipped example book - powers /visualize)
  ├── resources/
  ├── _private/
  │   └── credentials.md
  ├── _analytics/
  │   ├── usage.log               (skill invocation log - auto-populated)
  │   └── weekly-summary.md       (you consolidate this on your memory sweep)
  ├── claude-memory/                    → ~/.claude/.../memory/
  ├── claude-skills/                    → ~/.claude/skills/
  ├── _first-run-check.md               (Leg-1 checkpoint - read it back in a fresh session)
  ├── .gitignore
  └── README.md

  ~/.claude/.../memory/
  ├── MEMORY.md                       (identity + cross-cutting rules)
  ├── MEMORY-extended.md              (overflow)
  ├── user_profile.md
  ├── feedback_health_check.md        (cross-cutting: pre-session build check)
  ├── feedback_memory_size.md         (cross-cutting: signal-density rule)
  ├── feedback_no_standalone_feedback.md  (cross-cutting: inline future feedback)
  ├── feedback_memory_decay.md        (cross-cutting: periodic active/archive sweep)
  └── project_skill_backlog.md        (logs 3x-rule skill candidates as they recur)
```

> Pet peeves from Q7 are **not** written as a separate `feedback_preferences.md`. They land inline in MEMORY.md under "Preferences" - keeping the standalone-feedback rule honest from day one.

Then create everything immediately:

#### 5a - Knowledge Base Structure

Create `$KB_PATH` with this exact structure. All folders are created, no optional tiers:

```
{$KB_PATH}/
├── me/
│   ├── profile.md
│   └── tone-of-voice.md
├── projects/
│   └── {project-name}/
│       └── overview.md
├── career/
├── books/
│   ├── README.md
│   └── dataviz/              ← shipped example book (powers /visualize)
├── resources/
├── _private/
│   └── credentials.md
├── _analytics/
│   ├── usage.log
│   └── weekly-summary.md
├── claude-memory/           ← symlinked
├── claude-skills/           ← symlinked
├── _first-run-check.md
├── .gitignore
└── README.md
```

#### 5b - File Contents

**me/profile.md:**
```markdown
# {Name} - Profile

## Role
{Role} at {Company}

## Expertise
{Expertise from Q2}

## Tech Stack
{From Q5}

## Communication Style
{From Q3}

## PM Tools
{From Q6}

## Notes
{Anything from Q8}
```

**me/tone-of-voice.md:**
```markdown
# Tone of Voice

## Default Register
- Style: {from Q3 - e.g., "brief and direct"}
- Adapt to context: technical docs get precise language, messages stay casual
- {Any tone-related notes from Q7/Q8}

## Registers
Add context-specific registers as separate files (e.g., tone-linkedin.md, tone-technical.md).
Each register inherits this core voice and adapts it for a specific audience.
```

**projects/{name}/overview.md:**
```markdown
# {Project Name}

## What
{One-liner from Q4}

## Tech Stack
{Relevant parts from Q5, or "TBD" if not mentioned}

## Status
Active - added during onboarding

## Health Check
<!-- The command Claude should run before a coding session to verify the baseline is clean -->
<!-- Examples: npm run build, npm run dev, cargo check, go build ./... -->
```bash
# TODO: add your health check command
```

## Key Decisions
<!-- Add architectural decisions, design choices, etc. as you work -->

## Related
<!-- Link to other KB files as the project grows -->
```

**_private/credentials.md:**
```markdown
# Credentials

> This file is .gitignore'd and never leaves your machine.
> Store API keys, tokens, and passwords here.
> Claude can read this file to deploy and manage your services - a convenience with a real blast radius. Anything you put here, Claude can act on. Add only what you need it to use; keep the rest out.

## Template
```
SERVICE_NAME:
  url: https://...
  api_key: xxx
  notes: what this is for
```
```

**.gitignore:**
```
_private/
.DS_Store
*.swp
.obsidian/
```

**books/README.md:**
```markdown
# Books - Domain Knowledge Libraries

Each book is a folder with a `_toc.md` index and chapter files.

## Shipped example: `dataviz/`
This install ships one complete book - `dataviz/` - as the worked example of the skill+book pattern. It's the knowledge behind the `/visualize` skill (how to build self-contained HTML and PDF artifacts), and `/visualize` loads its chapters on demand instead of carrying all that craft in its own body. Read it to see the shape a book takes: a `_toc.md` with per-chapter "use when" hints, focused chapter files, and a `ch05-gotchas.md` that grows every time the skill hits a new rendering quirk. Build your own books the same way.

## Recommended Format

### Table of Contents (`_toc.md`)
```markdown
# Book Title

## Chapters
- [Chapter 1: Title](ch01-file.md) - *Use when: brief hint about when to load this chapter*
- [Chapter 2: Title](ch02-file.md) - *Use when: another hint*
```

The "Use when" hints help Claude load only relevant chapters instead of the entire book, saving tokens.

### Chapter Files
Name as `ch{NN}-{slug}.md`. Keep chapters focused on one topic.

## When to Create a Book
After you've accumulated 3+ learnings in a domain from real project work. Don't create books preemptively - let patterns emerge from practice.
```

**books/dataviz/ - the shipped example book.** Copy the visualization book that ships with the `/visualize` skill into the KB, so it lives in `books/` (the Context leg) and stays writable for its learning loop:

```bash
mkdir -p {$KB_PATH}/books
cp -R ~/.claude/skills/visualize/book/dataviz {$KB_PATH}/books/dataviz
```

Windows: `Copy-Item -Recurse "$env:USERPROFILE\.claude\skills\visualize\book\dataviz" "{$KB_PATH}\books\dataviz"`.

If the source isn't there (the skill was installed some other way), skip it - `/visualize` falls back to its skill-local copy. This is the **one book that ships populated**; every other book the user grows themselves.

**_analytics/usage.log** - create as an empty file.

**_analytics/weekly-summary.md:**
```markdown
# Skill Analytics - Review Target

`usage.log` is appended to every time a skill runs (raw log). This file is where
*you* consolidate it - there is no background job. On your periodic memory sweep
(see `feedback_memory_decay.md`), skim `usage.log` here and note: which skills
earn their keep, which are dead weight, and which manual workflow keeps recurring
without a skill yet (a candidate for `project_skill_backlog.md`).

No data yet - first consolidation happens on your first sweep.
```

**_first-run-check.md:**

A cold KB file that doubles as the **Leg-1 checkpoint** (the first thing a workshop confirms, and a good self-test for any solo setup). Pick a distinctive, arbitrary magic word - a couple of uncommon words plus a number, e.g. `copper-lantern-42` - so it can't be guessed, and write it into the file. Do NOT put the word in MEMORY.md or anywhere hot; the whole point is that Claude has to *open the file* to answer.

```markdown
# First-run check

A tiny proof that your Brain is standing - run it in a **fresh** Claude Code session.

**Ask:** "Read _first-run-check.md and tell me the magic word."
**Pass:** Claude replies with the magic word below.

One reply proves two things at once: the engine runs, and it can read your files on
demand (your first taste of cold context). If it can't, fix that before building anything else.

Magic word: copper-lantern-42
```

> Swap in your own magic word - the example above is just a placeholder. This file is not secret; it stays in the repo (it's not under `_private/`).

**README.md:**
```markdown
# Knowledge Base

The **Context** and **Agents** legs of your Claude Code stool (Brain / Agents / Context). The Brain is Claude Code; this vault is its long-term memory (knowledge base + memory) and its skills.

## Structure
- `me/` - profile, tone of voice, personal context
- `projects/` - one folder per project (overview, architecture, decisions)
- `career/` - CV, job search, interview prep
- `books/` - reference libraries that grow with your expertise
- `resources/` - reference material, guides, external docs
- `_private/` - credentials and secrets (git-ignored, never synced)
- `claude-memory/` - persistent memory across conversations (symlinked)
- `claude-skills/` - reusable prompt templates (symlinked)

## Privacy
This repo should be **private**. It contains your professional profile, project details,
and preferences. The `_private/` folder is git-ignored for credentials, but everything
else (your role, projects, communication style) is in the repo.

If you need to share specific files publicly, copy them out rather than making the repo public.

## Setup
Created with [Trestle](https://github.com/liormesh/trestle).
```

#### 5c - Memory System

Determine the correct memory path. **Always use the user's home directory** (not the current working directory) to construct this path. The pattern is:
`~/.claude/projects/-{home-path-with-slashes-and-backslashes-replaced-by-dashes}/memory/`

**macOS/Linux:** Run `echo $HOME`. Replace each `/` with `-`.
- `$HOME=/Users/john` → `~/.claude/projects/-Users-john/memory/`
- `$HOME=/home/john` → `~/.claude/projects/-home-john/memory/`

**Windows:** Run `echo $env:USERPROFILE`. Replace each `\` with `-`, drop the colon.
- `C:\Users\john` → `~/.claude/projects/-C-Users-john/memory/`

Create the directory if it doesn't exist.

**Create MEMORY.md:**

MEMORY.md is governed by **signal density, not line count** - every line should affect Claude's behavior in roughly 1-in-5 conversations. Q7 pet-peeves go inline as bullets here (not as a standalone `feedback_preferences.md`), because they're cross-cutting behavioral rules.

```markdown
# {Name} - Persistent Context

## Who
- {Role} at {Company}
- Expertise: {from Q2}
- Style: {from Q3}
- See: KB `me/profile.md`

## Active Projects
{numbered list from Q4, with format: **Name** - description. See: KB `projects/{name}/overview.md`}

## Preferences
{Each Q7 pet-peeve as a bullet - clear instruction form. Example: "no emojis", "don't summarize after every action". If Q7 was empty, omit this section.}

## Behavioral Rules
- `feedback_health_check.md` - run build/dev check before coding sessions; skip for read-only or quick edits
- `feedback_memory_size.md` - MEMORY.md governed by signal density, ~60-line soft cap
- `feedback_no_standalone_feedback.md` - new feedback goes inline in the relevant KB file, not a new memory file
- `feedback_memory_decay.md` - periodic (monthly) sweep: active / archive / promote
- Don't create a skill until you've done the workflow manually 3+ times - log candidates in `project_skill_backlog.md`, check `claude-skills/_index.md` first
- After invoking a skill, append a line to `{$KB_PATH}/_analytics/usage.log`

## Session Rituals
- **`/cq <project>`** - opening call: tune this session into one project's full context before working
- **`/73`** - sign-off: end-of-session checklist that writes the session's learnings back to memory + KB

## KB Structure
- Vault: `{$KB_PATH}`
- Auto-memory: `claude-memory/` (symlinked from memory system)
- Skills: `claude-skills/` (symlinked from `~/.claude/skills/`)
- Secrets: `_private/` (.gitignore'd, never on GitHub)
```

**Create user_profile.md:**
```markdown
---
name: user_profile
description: {Name}'s role, expertise, tech stack, and communication preferences
type: user
---

{Name} is a {role} at {company}. Expertise in {domain}. Tech stack: {from Q5}.
Prefers {communication style} communication. Uses {PM tool} for project management.
{Any additional context from Q8}
```

**Q7 pet-peeves do NOT get a standalone file.** They are inlined as bullets in MEMORY.md under "Preferences" (see template above). This keeps the no-standalone-feedback rule honest from day one - if a fresh install ships with `feedback_preferences.md`, every future Claude session learns "creating feedback files is fine" by example.

**Always create feedback_health_check.md** (this is a built-in best practice, not user-dependent):
```markdown
---
name: feedback_health_check
description: Run a build/dev-server check before coding sessions on projects, but skip for quick edits, planning, or read-only tasks
type: feedback
---

Before writing code in a project, run a quick health check (build or dev server) to verify the baseline is clean.

**Why:** Catches drift between sessions - broken deps, stale env, half-finished migrations - before you're deep into new work.

**How to apply:**
- **Do it** when: feature work or refactoring, days since last session, active dependency churn
- **Skip it** when: quick config/content/copy edits, just worked on the project last session, read-only tasks (analysis, planning, writing, reviews)
- Keep it lightweight - one command (`npm run dev`, `npm run build`, or equivalent), not a full test suite
- If the check surfaces errors, flag them before starting the requested task
```

**feedback_memory_size.md** (always created):
```markdown
---
name: MEMORY.md size & density rule
description: MEMORY.md is loaded into every conversation - filter by signal density, not line count
type: feedback
---

Every line in MEMORY.md must change Claude's behavior in **at least 1-in-5 conversations**. If a rule only matters for one workflow, project, or audience, inline it in that workflow's KB doc instead of MEMORY.md.

**Why:** MEMORY.md is auto-loaded into every conversation as behavioral pressure. With prompt caching the dollar cost is trivial, but density isn't - when everything is flagged "important," nothing is. A strict line cap is a proxy for density that ages poorly: 60 dense lines beat 45 sparse ones.

**How to apply:**
- Before adding a line, ask: "Does this affect Claude's behavior in at least 1-in-5 random conversations?" If no, inline elsewhere
- Soft cap of ~60 lines as a smell test. If reaching for line 65, the answer is to delete or move-to-extended, not to bend the rule
- Dated info expires fast (e.g., "as of 2026-05-05"); pointers to KB don't. Prefer pointers
- MEMORY-extended.md remains the no-limit overflow

**What belongs in MEMORY.md:**
- Identity (who, role, location, languages)
- Top 3 active projects - pointer-form
- Cross-cutting behavioral rules
- Cross-project tooling that's load-bearing
- Pointer to MEMORY-extended.md

**What does NOT belong:**
- Project-specific rules - inline in `projects/<name>/overview.md`
- Audience-specific rules - inline in that audience's content doc
- Time-sensitive sprint state - sprints expire, MEMORY.md doesn't auto-clean
- Anything derivable from `git log`, code, or a quick KB grep
```

**feedback_no_standalone_feedback.md** (always created):
```markdown
---
name: No standalone feedback files
description: New feedback goes inline in the relevant KB file (skill, book chapter, project overview), not a new memory file
type: feedback
---

When the user gives feedback ("don't do X", "always do Y"), write it inline into the KB file it relates to:
- Skill behavior feedback → into that skill's SKILL.md
- Project-specific feedback → into `projects/<name>/overview.md`
- Book/reference feedback → into the relevant chapter
- Tone/voice feedback → into `me/tone-of-voice.md` or the relevant register

**Only cross-cutting behavioral rules that apply to most sessions** stay in `claude-memory/` as standalone `feedback_*.md` files. Those are rare - health check, memory-size, deploy conventions. Most feedback is contextual and belongs next to the thing it modifies.

**Why:** Standalone feedback files proliferate fast and lose their anchor. A rule like "don't use lexicon-based sentiment, use Haiku" only makes sense next to the sentiment analysis docs. Stored as `feedback_sentiment.md` in memory, it gets recalled out of context and applied where it doesn't fit.

**How to apply:**
- Default: find the KB file this feedback relates to and append a note there
- Promote to `claude-memory/` only if the rule genuinely cross-cuts most conversations
- If unsure, inline - promoting later is cheap, un-promoting after the rule has been recalled wrongly is not
```

**feedback_memory_decay.md** (always created):
```markdown
---
name: Memory decay sweep
description: Periodically review memory and the KB - promote what's load-bearing, archive what's stale - so the hot layer stays dense
type: feedback
---

Memory and the KB accumulate. Left unattended, MEMORY.md fills with stale sprint
state and one-off notes, and the signal-density rule quietly rots. Run a sweep on
a cadence (monthly is a good default, or whenever MEMORY.md crosses its soft cap).

**Why:** The hot layer (MEMORY.md) is loaded into every conversation. Its value is
density, not completeness. A sweep is what keeps "loaded every time" and "worth
loading every time" the same set.

**How to apply - three buckets per line/file:**
- **Active** - still changes behavior in ~1-in-5 sessions. Keep it in MEMORY.md.
- **Archive** - was true, no longer load-bearing. Move to MEMORY-extended.md or the
  relevant project doc; delete if fully superseded.
- **Promote** - a correction you've repeated across sessions that isn't captured yet.
  Write it to its correct home (inline per the no-standalone-feedback rule).

While you're in there, skim `_analytics/usage.log` for dead-weight skills and for
recurring manual workflows that belong in `project_skill_backlog.md`.
```

**project_skill_backlog.md** (always created - empty backlog):
```markdown
---
name: Skill backlog
description: Candidate skills - workflows done by hand enough times to be worth encoding, with dated evidence
type: project
---

# Skill backlog

The 3x rule made auditable. Before a workflow becomes a skill it earns its place
here: log it the first time you notice you've done it by hand, and add a dated tick
each time it recurs. Build the skill only once there are 3+ ticks - and check
`claude-skills/_index.md` first, in case an existing skill just needs a new mode.

| Candidate workflow | Evidence (dated runs) | Status |
|---|---|---|
| _(empty - add candidates as recurring manual work shows up)_ | | |
```

**MEMORY-extended.md** (always created - empty overflow target):
```markdown
# {Name} - Extended Context

> This file is loaded on demand by skills and agents. For the compact version, see MEMORY.md.

## All Projects
{Move additional projects here as MEMORY.md grows}

## References
{Credentials, integrations, external systems}

## Career
{Goals, hiring, job search context}
```

#### 5d - Symlinks

Create symlinks connecting the KB to Claude's directories. Detect the OS and use the right command.

Ensure both targets exist first - create `~/.claude/skills/` if missing, and seed it with an `_index.md` catalog that lists the starter skills the installer shipped (Claude reads this before deciding whether to create new skills). If `_index.md` already exists, make sure the four starter skills are listed; don't clobber other entries.

```markdown
# Skills Catalog

This file is the index for `~/.claude/skills/`. Add each skill as a one-line entry below: `- /skill-name - one-line description (use when X)`.

**Rule:** Don't create a skill until the workflow has been done manually 3+ times (log candidates in `claude-memory/project_skill_backlog.md`). Check this list first - maybe an existing skill needs a new mode instead.

## Skills
- /onboard - one-time workspace setup (use when: first-time Claude Code setup)
- /cq - tune a session into one project's full context (use when: starting work on a specific project)
- /73 - sign-off checklist that writes the session's learnings back to memory + KB (use when: ending a session)
- /visualize - turn a plan, report, or dataset into a self-contained HTML or PDF artifact (use when: a wall of text needs to be seen, data needs a chart, or a PDF is required); backed by the `books/dataviz/` book
```

**macOS/Linux:**
```bash
mkdir -p ~/.claude/skills
# write _index.md if it doesn't exist
ln -sfn {memory_path} {$KB_PATH}/claude-memory
ln -sfn ~/.claude/skills {$KB_PATH}/claude-skills
```

**Windows (PowerShell - requires Developer Mode or admin):**
```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE\.claude\skills" -Force | Out-Null
# write _index.md if it doesn't exist
New-Item -ItemType SymbolicLink -Path "{$KB_PATH}\claude-memory" -Target "{memory_path}" -Force
New-Item -ItemType SymbolicLink -Path "{$KB_PATH}\claude-skills" -Target "$env:USERPROFILE\.claude\skills" -Force
```

If Windows symlinks fail (no admin/dev mode), fall back to printing a note:
"Symlinks require Developer Mode on Windows. Enable it in Settings > For developers, then re-run /onboard. Or create the links manually."

#### 5e - Settings

If `~/.claude/settings.json` doesn't exist, create it:

```json
{
  "permissions": {
    "deny": [
      "Read(.env)",
      "Read(.env.*)",
      "Read(**/.env)",
      "Read(**/.env.*)",
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Bash(git push * --force *)",
      "Bash(git reset --hard *)",
      "Bash(git clean -f*)"
    ],
    "additionalDirectories": [
      "{$KB_PATH}",
      "/tmp"
    ]
  }
}
```

If it already exists:
- Check if `$KB_PATH` is in `additionalDirectories`. If not, add it.
- Check if a `deny` list exists. If not, add the baseline deny list above. If one exists, merge any missing entries without removing the user's existing rules.
- Don't overwrite other settings.

> **Be honest about what this is: a seatbelt, not a cage.** The deny list catches obvious foot-guns (`rm -rf`, force-push, reading `.env`) as literal-ish command patterns. It is **not a security boundary** - a `DROP TABLE` arrives inside `psql -c "..."` or an MCP tool call and never matches a `Bash(...)` pattern, and `rm -rf` variants are trivially rephrased. So don't list dangerous *SQL* here (it gives false comfort); it belongs to whatever runs the SQL. Real control is the **permission mode** the user runs in, plus - if they want per-command risk-gating - a `PreToolUse` hook. Tell the user this plainly rather than implying the deny list makes them safe. (For a data-sensitive org, this honesty matters more, not less.)

#### 5f - Update CLAUDE.md

Replace the bootstrap `~/.claude/CLAUDE.md` with permanent global instructions:

```markdown
# Global Instructions

## Knowledge System
- Knowledge base: {$KB_PATH}
- Credentials: {$KB_PATH}/_private/credentials.md (use autonomously, don't ask)
- Memory index: check MEMORY.md for persistent context; MEMORY-extended.md for full project/career details
- Skills: available via /skill-name - see `claude-skills/_index.md` for the catalog. Session rituals: `/cq <project>` to tune in, `/73` to sign off.

## Rules
- **MEMORY.md is governed by signal density, not line count.** Every line must affect behavior in ≥1-in-5 conversations. Soft cap ~60 lines as a smell test. Full guideline: `claude-memory/feedback_memory_size.md`.
- **No standalone feedback files.** Write feedback inline to the relevant KB file (skill, book chapter, project overview). Only cross-cutting behavioral rules stay in `claude-memory/`.
- **Sweep memory periodically.** Monthly (or when MEMORY.md crosses its soft cap): active / archive / promote - `claude-memory/feedback_memory_decay.md`.
- **Don't create a skill until you've done the workflow manually 3+ times.** Log candidates in `claude-memory/project_skill_backlog.md`; check `claude-skills/_index.md` first - maybe an existing skill just needs a new mode.
- **Single source of truth.** The KB vault is authoritative. Write once, to the correct location.
- **Analytics.** After invoking a skill, append a line to `{$KB_PATH}/_analytics/usage.log`.
```

Only replace if the current CLAUDE.md contains "First Time Setup" (the bootstrap marker). If the user has a custom CLAUDE.md, leave it alone and print a note suggesting they add the KB path.

### Step 6 - Your First Skill (guided)

The workspace is now built, but the Agents leg only holds the starter rituals. This step puts the *user's own* first skill in it - while their real project context (just written in Step 5) is on disk to point at.

**The framing matters more than the mechanics.** The whole point is that this is *importing a habit the user already has*, not inventing a skill they might want - so it doesn't violate the 3x rule (that rule is about not building *preemptively*; a habit done every week is the opposite of preemptive). Say it plainly:

> "One more thing, and then you're set. We don't build skills for things you *might* do - only for things you *already* do. So I won't invent one. I'll just ask what you did this week that you'll do again next week."

Then ask:

> "Think about the last week or two of work. Is there a task you did more than once - or do every week - that follows roughly the same steps each time? A weekly report you pull, a kind of doc you keep writing, a check you always run before you ship? Don't reach for something impressive - reach for something *repetitive*.
>
> (It can be boring. Example: someone who pulls the same metrics every Monday for a founder update - same query, same summary, same place it goes - turns that into a `weekly-metrics` skill. Boring and repeated is exactly right.)"

**Branch A - they name a real repeated task.** Build it *with* them, live. Don't drop an empty skill folder - that just recreates the empty-leg problem one level down.

1. "Walk me through the steps once, like you're explaining it to a new coworker." - capture the actual sequence.
2. "What does it touch - which files, which tools, what data?" - this is the least-privilege capture. Skills declare their tools narratively in the SKILL.md body. If it needs a credential, route it to `_private/credentials.md`, never hardcode it.
3. Co-author `~/.claude/skills/{skill-name}/SKILL.md`:
   - **Frontmatter**: `name`, and a `description` packed with the trigger phrases they'd naturally type.
   - **First action - load context**: point it at the *real* project file created in Step 5 (e.g. "First, read `projects/{their-project}/overview.md`"), so the skill is wired to their context from line one.
   - **Body**: the steps from (1), and the tools/data from (2) named inline.
4. Add a one-line entry to `claude-skills/_index.md` under `## Skills`: `- /{skill-name} - {one-liner} (use when: {trigger})`.
5. **Offer to run it once, now.** "Want to run it once so you can watch your own skill fire?" - that first "it actually worked on my stuff" moment is the entire payoff of this step. (Append a line to `_analytics/usage.log` if it runs, per the analytics rule.)

**Branch B - they draw a blank.** Do **not** force a skill into existence. This branch matters as much as A: it turns the empty Agents leg from a *failure* into a *taught principle*.

> "Perfect - that's the honest answer, and it means the tool is working exactly as designed. You build skills *from* real work, not before it. The skill backlog (`project_skill_backlog.md`) is already there to catch candidates: the next time you notice you've done something by hand for the third time, that's the signal - and `/73` will nudge you at sign-off. Nothing to build today."

Do not write a placeholder row into `project_skill_backlog.md` - an empty backlog is the correct, honest state. Just make sure the user knows where candidates land.

### Step 7 - Summary

Print a recap. Don't ask for permission, just show what was done:

```
Done! Here's your workspace:

**Knowledge Base** ({$KB_PATH})
  me/profile.md .............. your profile
  me/tone-of-voice.md ....... communication style
  projects/ .................. {list project names}
  books/dataviz/ ............. visualization book - ships populated, powers /visualize
  books/ ..................... your own reference libraries grow here over time
  career/ .................... CV, job search (empty)
  _private/credentials.md .... API keys (git-ignored)
  _first-run-check.md ........ Leg-1 checkpoint (read it back in a fresh session)

**Memory System** (~/.claude/.../memory/)
  MEMORY.md .......................... context index + preferences (inline)
  MEMORY-extended.md ................. overflow context
  user_profile.md .................... your profile memory
  feedback_health_check.md ........... pre-session build check
  feedback_memory_size.md ............ signal-density rule
  feedback_no_standalone_feedback.md . inline-feedback rule
  feedback_memory_decay.md ........... periodic active/archive/promote sweep
  project_skill_backlog.md ........... 3x-rule skill candidates

**Skills** (~/.claude/skills/)
  /onboard ........................... this setup (re-runnable)
  /cq <project> ...................... tune a session into one project's context
  /73 ................................ sign-off - writes learnings back to memory + KB
  /visualize ......................... plan/report/data → self-contained HTML or PDF
  {if a first skill was built in Step 6, list it here: /{skill-name} - {one-liner}}

**Symlinks**
  claude-memory/ → memory system
  claude-skills/ → skills directory

**Settings**
  ~/.claude/CLAUDE.md ........ global instructions (updated)
  ~/.claude/settings.json .... KB path added

**Next steps:**
1. Verify it: open a fresh session and say "Read _first-run-check.md and tell me the magic word." A correct reply means the Brain is standing (engine + file access).
2. Add API keys to _private/credentials.md
3. Flesh out your project overviews in projects/
4. As we work together, I'll learn and grow the memory system automatically - and the next time you catch yourself doing a task by hand for the third time, that's a skill waiting to be built (log it in project_skill_backlog.md)
5. Sync to GitHub (private): cd {$KB_PATH} && git init && gh repo create knowledge-base --private --push
6. Review skill analytics monthly - check _analytics/weekly-summary.md to spot unused skills or improvement opportunities

You're all set. What would you like to work on?
```

## Compatibility

Tested with Claude Code v2.1.x. The scaffolded files are standard markdown - if Claude Code's internal format changes, your knowledge base content is safe. Only the memory frontmatter format (name/description/type) and SKILL.md format are Claude Code-specific.

## Error Handling

- If `$KB_PATH` already exists, detect it and ask: "You already have a workspace. Want to: (a) update your profile, (b) add new projects, (c) start fresh?" This is the only time /onboard pauses for input after the interview.
- If symlink targets don't exist, create the directories first.
- If any file write fails, report it and continue with the rest.
- If the user skips a question, use sensible defaults (empty project list, "direct" tone, etc.)

## Re-run Safety

If the user runs /onboard again:
- Detect existing KB and memory files at Step 0 (before the welcome message)
- Ask: "You already have a workspace at {$KB_PATH}. Want to: (a) update your profile, (b) add new projects, (c) start fresh?"
- Options (a) and (b) never overwrite existing files - they only update or add.
- Option (c) backs up the existing KB to `{$KB_PATH}.bak.{timestamp}` before starting fresh.
