---
name: onboard
description: Interactive onboarding for new Claude Code users. Interviews the user about their role, projects, preferences, and tools, then scaffolds their entire AI workspace - knowledge base, memory system, profile, settings, and folder structure. Run once on first setup. Triggers on 'onboard', 'set up my workspace', 'first time setup', 'get started'.
---

# /onboard - Claude Code Workspace Setup

## Overview

You are an onboarding assistant. Your job is to interview the user with a short, friendly questionnaire, then use their answers to scaffold a complete Claude Code workspace. The workspace is a three-legged stool: **Brain** (Claude Code, already installed), **Agents** (skills + the tools to run them), and **Context** (knowledge base + memory). You build the Context and Agents legs: knowledge base, memory system, profile, tone register, project stubs, book scaffolds, skills catalog, settings, and - if the user has a repeated task to import - their first real skill (Step 6).

**Starter agents already installed.** The install step ships four skills into `~/.claude/skills/`: `/onboard` (this one), `/cq` (tune a session into one project's context), `/73` (sign-off - writes the session's learnings back to memory and the KB), and `/visualize` (turn a plan, report, or dataset into a self-contained HTML or PDF artifact). `/cq` and `/73` are the two rituals that run the growth loop; `/visualize` is a ready working skill - and the **worked example of a skill paired with a book**: it ships with a `dataviz` book that you copy into `books/` in Step 5, and the skill loads its chapters on demand. The user has agents to inspect and use from day one, before they build their own. Your job is to make sure the catalog and rules reference them, and to copy the visualize book into the KB.

**Guardrails already installed.** The installer also put three small Node tools in `~/.claude/trestle/`: a **secret guard** and a **link guard** (you register them as hooks in Step 5e) and **`kb-check.mjs`**, the health check `/73` runs at every sign-off. The framework's lesson from real use: rules written in memory get forgotten; checks that run on their own don't. The shipped rule files live in `templates/` next to this skill.

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

**Shipped files come from `templates/`** next to this SKILL.md (`~/.claude/skills/onboard/templates/`). Copy them as-is, replacing only `{KB_PATH}` where it appears - don't paraphrase them. They are shipped verbatim on purpose: `/onboard` option (d) diffs the installed copies against newer templates on upgrade, which only works if the installed copy started out identical.

Print the tree preview:

```
Creating:

  {$KB_PATH}/
  ├── me/
  │   ├── profile.md
  │   └── tone-of-voice.md
  ├── projects/
  │   └── {project-name}/overview.md   ← one per project, with a state: field
  ├── pm/
  │   └── handoff/
  │       ├── README.md                (where live project status lives)
  │       └── {project-name}-resume-prompt.md   ← one per project, what /cq reads first
  ├── career/
  ├── books/
  │   ├── README.md                     (how to structure your own books)
  │   └── dataviz/                      (shipped example book - powers /visualize)
  ├── resources/
  ├── _private/
  │   └── credentials.md
  ├── _analytics/
  │   └── usage.log                     (one line per skill run - the sweep reads it)
  ├── claude-memory/                    → ~/.claude/.../memory/
  ├── claude-skills/                    → ~/.claude/skills/
  ├── _first-run-check.md               (Leg-1 checkpoint - read it back in a fresh session)
  ├── .gitignore
  └── README.md

  ~/.claude/.../memory/
  ├── MEMORY.md                         (identity + cross-cutting rules + pointers)
  ├── MEMORY-extended.md                (overflow)
  ├── user-profile.md
  ├── feedback-health-check.md          (pre-session build check)
  ├── feedback-memory-size.md           (signal density + no live status in the index)
  ├── feedback-no-standalone-feedback.md (inline future feedback)
  ├── feedback-memory-decay.md          (the sweep - triggered by /73)
  └── project-skill-backlog.md          (3x-rule skill candidates)

  ~/.claude/
  ├── CLAUDE.md                         (global instructions)
  ├── settings.json                     (KB access + seatbelt deny list + 2 hooks)
  └── trestle/                          (installed tools: secret guard, link guard, health check)
      └── config.json                   (where your KB and memory live)
```

> Pet peeves from Q7 are **not** written as a separate feedback file. They land inline in MEMORY.md under "Preferences" - keeping the standalone-feedback rule honest from day one.

Then create everything immediately:

#### 5a - Knowledge Base Structure

Create `$KB_PATH` with exactly the tree above. All folders are created, no optional tiers.

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

**projects/{name}/overview.md** - the stable description of the project. Its frontmatter carries the project's **state**, and only this file carries it:

```markdown
---
title: {Project Name}
state: project
state_changed: {today, YYYY-MM-DD}
---

# {Project Name}

## What
{One-liner from Q4}

## Tech Stack
{Relevant parts from Q5, or "TBD" if not mentioned}

## Health Check
<!-- The one command Claude runs before a coding session to verify the baseline is clean -->
<!-- Examples: npm run build, npm run dev, cargo check, go build ./... -->
```bash
# TODO: add your health check command
```

## Key Decisions
<!-- Architectural decisions, design choices, and why - as you make them -->

## Related
- Live status and next steps: `pm/handoff/{project-name}-resume-prompt.md`
```

`state:` is one of four values - set every onboarded project to `project`, then explain the other three once in the Step 7 summary:

| value | means | litmus test |
|---|---|---|
| `project` | a finishable push happening **now** | "Is there a finish line, and am I pushing it this week?" |
| `area` | a live thing you **maintain**, no end | "Is this a responsibility that runs fine without a sprint?" |
| `archive` | had a life, now dormant - could resume | "Was this active, now cold?" |
| `icebox` | an idea you chose not to build | "Did I decide not to pursue this?" |

"What's in flight?" is then a grep, not a re-read: `grep -l "^state: project" projects/*/overview.md`. A `project` whose `state_changed` is 45+ days old is flagged by `/73` - a project is supposed to finish; one that hasn't moved is a decision nobody made.

**pm/handoff/README.md** - copy `templates/kb/handoff-readme.md`.

**pm/handoff/{project-name}-resume-prompt.md** - one per project:
```markdown
---
title: {Project Name} - resume prompt
---

# {Project Name} - resume prompt

> Living doc: rewrite in place. `/cq {project-name}` reads this first.

## Finish line
{What "done" looks like for the current push - ask nothing; leave "TBD - set on first working session" if Q4 didn't say}

## In flight
- Nothing yet - onboarded {today}

## Next step
- 

## Gotchas this week
- 
```

**_private/credentials.md** - copy `templates/kb/credentials.md`.

**.gitignore** - copy `templates/kb/gitignore`.

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

**_analytics/usage.log** - create with one line, so the format is visible by example:
```
{ISO-UTC now, e.g. 2026-11-01T09:30:00Z} onboard first run
```
One line per skill run, exactly `<ISO-UTC> <skill-name> <short note>`. There is no consolidation file to keep up: the memory sweep reads the log with `node ~/.claude/trestle/kb-check.mjs --usage 30`.

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
- `projects/` - one folder per project; `overview.md` is the stable description and carries `state:`
- `pm/handoff/` - live status per project (`<project>-resume-prompt.md`, what `/cq` reads first)
- `career/` - CV, job search, interview prep
- `books/` - reference libraries that grow with your expertise
- `resources/` - reference material, guides, external docs
- `_private/` - credentials and secrets (git-ignored, never synced)
- `_analytics/` - skill usage log + the health-check baseline
- `claude-memory/` - persistent memory across conversations (symlinked)
- `claude-skills/` - skills (symlinked)

## How it stays healthy
- `/73` at the end of a session runs a health check: broken links, unindexed memory, secrets in files, stale projects, an overdue memory sweep. A ratchet (`_analytics/baseline.json`) means vault-wide problem counts can go down, never up.
- Two hooks run on every write Claude makes here: a secret guard (blocks credential-shaped values outside `_private/`) and a link guard (reports links that point at nothing).
- Run the check yourself any time: `node ~/.claude/trestle/kb-check.mjs`

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

**Memory file conventions** (every file you write here, and every one the user adds later):
- Filename `<type>-<slug>.md`, kebab-case: `feedback-health-check.md`, `project-skill-backlog.md`. Never underscores.
- Frontmatter `name:` equals the filename without `.md`, plus a one-line `description:` and the type. Use the frontmatter shape your Claude Code version writes for its own memories (current versions nest it as `metadata:` → `type:`; older ones use a top-level `type:`) - the health check accepts both.
- Every memory file gets a one-line pointer in MEMORY.md or MEMORY-extended.md. An unindexed memory file can never be recalled - `/73` flags them.

**Create MEMORY.md:**

MEMORY.md is governed by **signal density and volatility, not line count** - every line should affect Claude's behavior in roughly 1-in-5 conversations, and nothing that changes week to week goes in it (live status lives in `pm/handoff/`). Q7 pet-peeves go inline as bullets here, because they're cross-cutting behavioral rules.

```markdown
# {Name} - Persistent Context

*Index only: stable hooks + pointers. Live status lives in each project's `pm/handoff/<project>-resume-prompt.md`.*

## Who
- {Role} at {Company}
- Expertise: {from Q2}
- Style: {from Q3}
- See: KB `me/profile.md`

## Projects
- **What's in flight?** grep `state: project` across `projects/*/overview.md` - never answer from this list.
{one line per project from Q4: **Name** - what it is (no status). → `projects/{name}/overview.md`}

## Preferences
{Each Q7 pet-peeve as a bullet - clear instruction form. Example: "no emojis", "don't summarize after every action". If Q7 was empty, omit this section.}

## Behavioral Rules
- `feedback-health-check.md` - run build/dev check before coding sessions; skip for read-only or quick edits
- `feedback-memory-size.md` - signal density + no live status in this index; ~100-line smell test
- `feedback-no-standalone-feedback.md` - new feedback goes inline in the relevant KB file, not a new memory file
- `feedback-memory-decay.md` - the sweep (active / archive / promote), triggered when /73 reports it overdue
- `project-skill-backlog.md` - don't create a skill until the workflow was done by hand 3+ times; check `claude-skills/_index.md` first
- After invoking a skill, append `<ISO-UTC> <skill> <note>` to `{$KB_PATH}/_analytics/usage.log`

## Session Rituals
- **`/cq <project>`** - opening call: tune this session into one project (reads its handoff doc + overview)
- **`/73`** - sign-off: health check, then write the session's learnings back to memory + KB

## KB Structure
- Vault: `{$KB_PATH}` · overflow: `MEMORY-extended.md`
- Auto-memory: `claude-memory/` (symlinked from memory system)
- Skills: `claude-skills/` (symlinked from `~/.claude/skills/`)
- Secrets: `_private/` (.gitignore'd, never on GitHub)
```

**Create user-profile.md:**
```markdown
---
name: user-profile
description: {Name}'s role, expertise, tech stack, and communication preferences
metadata:
  type: user
---

{Name} is a {role} at {company}. Expertise in {domain}. Tech stack: {from Q5}.
Prefers {communication style} communication. Uses {PM tool} for project management.
{Any additional context from Q8}
```

**Copy the shipped rule files** from `templates/memory/` into the memory directory, unchanged: `feedback-health-check.md`, `feedback-memory-size.md`, `feedback-no-standalone-feedback.md`, `feedback-memory-decay.md`, and `project-skill-backlog.md` (an empty backlog). These are built-in best practices, not user-dependent. Each carries a `trestle:` version stamp in its frontmatter - leave it; option (d) uses it to tell shipped rules from ones the user has edited.

**MEMORY-extended.md** (always created - empty overflow target):
```markdown
# {Name} - Extended Context

> This file is loaded on demand by skills and agents. For the compact version, see MEMORY.md.

## All Projects
{Move additional projects here as MEMORY.md grows}

## References
{Integrations, external systems - pointers, never secret values}

## Career
{Goals, hiring, job search context}
```

#### 5d - Symlinks

Create symlinks connecting the KB to Claude's directories. Detect the OS and use the right command.

Ensure both targets exist first - create `~/.claude/skills/` if missing, and seed it with an `_index.md` catalog that lists the starter skills the installer shipped (Claude reads this before deciding whether to create new skills). If `_index.md` already exists, make sure the four starter skills are listed; don't clobber other entries.

```markdown
# Skills Catalog

This file is the index for `~/.claude/skills/`. Add each skill as a one-line entry below: `- /skill-name - one-line description (use when X)`.

**Rule:** Don't create a skill until the workflow has been done manually 3+ times (log candidates in `claude-memory/project-skill-backlog.md`). Check this list first - maybe an existing skill needs a new mode instead.

## Skills
- /onboard - workspace setup, and option (d) to update the framework (use when: first-time setup, or after re-running the installer)
- /cq - tune a session into one project's full context (use when: starting work on a specific project)
- /73 - sign-off: health check + writes the session's learnings back to memory + KB (use when: ending a session)
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

#### 5e - Settings, hooks and tool config

**Tool config.** Write `~/.claude/trestle/config.json` (the installer created the folder and put the tools in it). Absolute paths, forward slashes even on Windows:

```json
{
  "kb_path": "{absolute $KB_PATH}",
  "memory_path": "{absolute memory_path}",
  "workspace_version": "{contents of ~/.claude/trestle/VERSION}",
  "installed": "{today, YYYY-MM-DD}"
}
```

If `~/.claude/trestle/` doesn't exist (the skill was copied by hand, not by the installer), skip the config and the hooks below, and tell the user to run the installer one-liner to get them.

**settings.json.** If `~/.claude/settings.json` doesn't exist, create it. `{HOME}` = the absolute home directory with forward slashes (`/Users/john`, `C:/Users/john`):

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
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit|NotebookEdit",
        "hooks": [{ "type": "command", "command": "node \"{HOME}/.claude/trestle/secret-guard.mjs\"" }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [{ "type": "command", "command": "node \"{HOME}/.claude/trestle/link-guard.mjs\"" }]
      }
    ]
  }
}
```

If it already exists:
- Check if `$KB_PATH` is in `additionalDirectories`. If not, add it.
- Check if a `deny` list exists. If not, add the baseline deny list above. If one exists, merge any missing entries without removing the user's existing rules.
- Add the two hook entries if no existing hook command mentions `trestle/secret-guard.mjs` / `trestle/link-guard.mjs`. Append to existing `PreToolUse` / `PostToolUse` arrays; never replace the user's hooks.
- Don't overwrite other settings.

**What the two hooks do** (tell the user in one line each):
- **Secret guard** (before every write into the KB, memory or skills): blocks the write if it contains a credential-shaped value - API key, token, private key - anywhere except `_private/`. Once a key is committed, deleting it later doesn't remove it from git history; the only fix is rotating the key. Blocking it at write time is cheap.
- **Link guard** (after every markdown write there): reports links that point at nothing, with a did-you-mean, so Claude fixes them in the same turn.

> **Be honest about what all of this is: a seatbelt, not a cage.** The deny list catches obvious foot-guns (`rm -rf`, force-push, reading `.env`) as literal-ish command patterns. It is **not a security boundary** - a `DROP TABLE` arrives inside `psql -c "..."` or an MCP tool call and never matches a `Bash(...)` pattern, and `rm -rf` variants are trivially rephrased. The secret guard sees writes made through Claude's edit tools, not text a shell command writes. Real control is the **permission mode** the user runs in. Tell the user this plainly rather than implying the setup makes them safe. (For a data-sensitive org, this honesty matters more, not less.)

The hooks need Node.js 18+ on the PATH (`node --version`). If it's missing, the hooks fail open (Claude Code shows a hook error and carries on) - say so and point to nodejs.org.

#### 5f - Update CLAUDE.md

Replace the bootstrap `~/.claude/CLAUDE.md` with permanent global instructions: copy `templates/kb/claude-md.md`, replacing every `{KB_PATH}` with the absolute KB path. Keep the `<!-- trestle:rules:start -->` / `<!-- trestle:rules:end -->` markers - option (d) refreshes only what's between them, so anything the user adds outside the markers survives upgrades.

Only replace if the current CLAUDE.md contains "First Time Setup" (the bootstrap marker). If the user has a custom CLAUDE.md, leave it alone: append the template's marked block to the end of it, and tell them you did.

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

> "Perfect - that's the honest answer, and it means the tool is working exactly as designed. You build skills *from* real work, not before it. The skill backlog (`project-skill-backlog.md`) is already there to catch candidates: the next time you notice you've done something by hand for the third time, that's the signal - and `/73` will nudge you at sign-off. Nothing to build today."

Do not write a placeholder row into `project-skill-backlog.md` - an empty backlog is the correct, honest state. Just make sure the user knows where candidates land.

### Step 7 - Summary

Print a recap. Don't ask for permission, just show what was done:

```
Done! Here's your workspace:

**Knowledge Base** ({$KB_PATH})
  me/profile.md .............. your profile
  me/tone-of-voice.md ....... communication style
  projects/ .................. {list project names} - each overview has state: project
  pm/handoff/ ................ live status per project (what /cq reads first)
  books/dataviz/ ............. visualization book - ships populated, powers /visualize
  books/ ..................... your own reference libraries grow here over time
  career/ .................... CV, job search (empty)
  _private/credentials.md .... API keys (git-ignored)
  _first-run-check.md ........ Leg-1 checkpoint (read it back in a fresh session)

**Memory System** (~/.claude/.../memory/)
  MEMORY.md .......................... index: identity, rules, pointers (no live status)
  MEMORY-extended.md ................. overflow context
  user-profile.md .................... your profile memory
  feedback-health-check.md ........... pre-session build check
  feedback-memory-size.md ............ signal density + no live status in the index
  feedback-no-standalone-feedback.md . inline-feedback rule
  feedback-memory-decay.md ........... the sweep - /73 tells you when it's due
  project-skill-backlog.md ........... 3x-rule skill candidates

**Skills** (~/.claude/skills/)
  /onboard ........................... this setup (re-runnable; option (d) updates the framework)
  /cq <project> ...................... tune a session into one project's context
  /73 ................................ sign-off - health check, then writes learnings back
  /visualize ......................... plan/report/data → self-contained HTML or PDF
  {if a first skill was built in Step 6, list it here: /{skill-name} - {one-liner}}

**Guardrails** (~/.claude/trestle/ + settings.json)
  secret guard ....................... blocks API keys written outside _private/
  link guard ......................... reports links that point at nothing
  health check ....................... /73 runs it; a ratchet keeps problem counts from creeping up

**Settings**
  ~/.claude/CLAUDE.md ........ global instructions (updated)
  ~/.claude/settings.json .... KB access + seatbelt deny list + 2 hooks

**Project states** - every project starts as `project` (a push with a finish line).
When one becomes something you just maintain, change it to `area`; parked = `archive`;
an idea you won't build = `icebox`. Update `state_changed:` when you do.

**Next steps:**
1. Verify it: open a fresh session and say "Read _first-run-check.md and tell me the magic word." A correct reply means the Brain is standing (engine + file access).
2. Add API keys to _private/credentials.md
3. Start each work session with /cq <project>, end it with /73. That pair is the whole maintenance routine - /73 tells you when anything else (the memory sweep, a stale project) is due.
4. The next time you catch yourself doing a task by hand for the third time, that's a skill waiting to be built - /73 will ask.
5. Sync to GitHub (private): cd {$KB_PATH} && git init && gh repo create knowledge-base --private --push

You're all set. What would you like to work on?
```

## Option (d) - Update the framework

For a workspace that already exists, after the user re-ran the installer one-liner (which refreshes the starter skills, templates and tools, and backs up the old skills to `~/.claude/trestle/backups/`). The goal: bring the framework's own files up to the installed version **without touching the user's content**. Their projects, profile, notes, books and own memories are never rewritten.

Work through these in order. Show a short plan first (what will change, what will be renamed), then do it - one confirmation for the whole batch, not per file, except where noted.

1. **Versions.** Read `~/.claude/trestle/VERSION` (installed tools) and `~/.claude/trestle/config.json` → `workspace_version` (missing config = a pre-1.8 workspace). Find `$KB_PATH` from the config, or from `~/.claude/CLAUDE.md`'s "Knowledge base:" line. Tell the user: "Updating your workspace from v{old} to v{new}."

2. **Rename legacy memory files** (pre-1.8 used underscores and title-style names). In the memory directory, rename `feedback_health_check.md` → `feedback-health-check.md`, `feedback_memory_size.md` → `feedback-memory-size.md`, `feedback_no_standalone_feedback.md` → `feedback-no-standalone-feedback.md`, `feedback_memory_decay.md` → `feedback-memory-decay.md`, `project_skill_backlog.md` → `project-skill-backlog.md`, `user_profile.md` → `user-profile.md`, and any other `<type>_<slug>.md` the user created → `<type>-<slug>.md`. Set each renamed file's `name:` to its new filename stem. Then **fix every reference**: grep MEMORY.md, MEMORY-extended.md, `~/.claude/CLAUDE.md`, `claude-skills/_index.md`, the skills and the KB for the old names, and replace them.

3. **Refresh the shipped rule files.** For each file in `templates/memory/` (except `project-skill-backlog.md` - that one holds the user's data; only rename it):
   - Installed copy identical to the template → nothing to do.
   - Installed copy identical to the *previous* template (the installer backed up the previous `/onboard` skill, templates included, to the newest folder in `~/.claude/trestle/backups/`) → the user never edited it: replace it with the new template, no question.
   - Pre-1.8 (no stamp) or edited by the user → show a short summary of what the new version changes, and ask: **replace** (the old copy goes to `~/.claude/trestle/backups/`), **keep mine**, or **merge** (new template + the user's additions carried over). This is the one place to ask per file - it's their memory.

4. **Global CLAUDE.md.** If it has the `trestle:rules` markers, replace the block between them with the new `templates/kb/claude-md.md` block (`{KB_PATH}` filled in). If it has no markers (pre-1.8), show the user the new block next to their current Rules section and offer to swap their Rules/Knowledge-System sections for the marked block. Never touch text outside the markers.

5. **Add what's new in the KB** (only if missing - never overwrite):
   - `pm/handoff/README.md` from the template, and a `{project}-resume-prompt.md` stub for each project folder. If a project overview has a free-text `## Status` section, move its contents into the new resume prompt and remove it from the overview.
   - `state:` + `state_changed:` frontmatter on every `projects/*/overview.md` that lacks it. Ask the user once, as a single list: "which of these are you actively pushing (`project`), maintaining (`area`), parked (`archive`), or not pursuing (`icebox`)?" Default to `project`. Remove any `state:` found on non-overview docs.
   - `.gitignore`: append the template lines the user's file doesn't already have.
   - `_private/credentials.md`: add the template's two new caveat lines (committed keys = rotate; production keys in a secret manager) under the existing header, if missing.
   - `_analytics/usage.log`: if it has lines not in `<ISO-UTC> <skill> <note>` format, offer to normalize them (keep the data, fix the shape). `_analytics/weekly-summary.md` is retired - tell the user it's no longer used and offer to delete it.
   - MEMORY.md: add the "What's in flight? grep `state: project`" pointer line under the projects section, and offer to move any live status lines (dates, "this week", "waiting on") into the matching resume prompt. Show the lines first.

6. **Hooks and config.** Write/refresh `~/.claude/trestle/config.json` (step 5e) and add the two hooks to `settings.json` if absent (merge, never replace).

7. **Stamp and verify.** Set `workspace_version` in the config to the installed VERSION. Run `node ~/.claude/trestle/kb-check.mjs --hours 1` once and show the result - the first run creates the ratchet baseline, so pre-existing problems are recorded, not blamed on this session. Tell the user what the baseline found (e.g. "12 broken links already in the vault - the ratchet won't let that number grow, and every one you fix lowers it").

8. **Recap:** what was renamed, refreshed, added, and kept - and where backups went.

## Compatibility

Tested with Claude Code v2.1.x. Hooks and the health check need **Node.js 18+**. The scaffolded files are standard markdown - if Claude Code's internal format changes, your knowledge base content is safe. Only the memory frontmatter (name/description/type) and SKILL.md format are Claude Code-specific.

## Error Handling

- If `$KB_PATH` already exists, see Re-run Safety. This is the only time /onboard pauses for input after the interview (plus the per-file choices in option (d)).
- If symlink targets don't exist, create the directories first.
- If any file write fails, report it and continue with the rest.
- If a write is blocked by the secret guard, the user put a key into an interview answer: write it to `_private/credentials.md` instead and keep a pointer in the original file.
- If the user skips a question, use sensible defaults (empty project list, "direct" tone, etc.)

## Re-run Safety

If the user runs /onboard again:
- Detect existing KB and memory files at Step 0 (before the welcome message)
- Ask: "You already have a workspace at {$KB_PATH}. Want to: (a) update your profile, (b) add new projects, (c) start fresh, or (d) update the framework (after re-running the installer)?"
- If `~/.claude/trestle/VERSION` is newer than the workspace's `workspace_version` (or the config is missing), say so and recommend (d).
- Options (a), (b) and (d) never overwrite the user's content - they only update or add. New projects in (b) get the overview frontmatter and a resume-prompt stub, like Step 5.
- Option (c) backs up the existing KB to `{$KB_PATH}.bak.{timestamp}` before starting fresh.
