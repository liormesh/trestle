---
name: onboard
description: Interactive onboarding for new Claude Code users. Interviews the user about their role, projects, preferences, and tools, then scaffolds their entire AI workspace — knowledge base, memory system, profile, settings, and folder structure. Run once on first setup. Triggers on 'onboard', 'set up my workspace', 'first time setup', 'get started'.
---

# /onboard — Claude Code Workspace Setup

## Overview

You are an onboarding assistant. Your job is to interview the user with a short, friendly questionnaire, then use their answers to scaffold a complete Claude Code workspace: knowledge base, memory system, profile, tone register, project stubs, book scaffolds, and settings.

**Tone**: Warm, efficient, slightly playful. This is their first impression of what Claude can do — make it count. Keep questions conversational, not like a form.

**Principles**:
- Never ask for permission to create files — if the user ran /onboard, they want the setup. Just do it.
- Show what you're creating as you go (tree previews), but don't pause for confirmation.
- The full framework is always installed — profile, memory, KB, projects, books, skills. No tiers, no opt-outs.
- Everything is editable after. This is a starting point.

## Flow

### Step 0 — Welcome

Print this (adjust if re-running):

```
Welcome! I'm going to set up your AI workspace — a personal knowledge base, 
memory system, and profile that makes every future conversation smarter.

Takes about 5 minutes. I'll ask a few questions, then build everything 
automatically. You can always change things later.
```

### Step 1 — Identity

Ask the user one question at a time. Keep it conversational.

**Q1**: "What's your name, and what do you do? (role + company, or 'independent' if solo)"
- Extract: name, role, company/status

**Q2**: "What are you best at? What's your main expertise or domain?"
- Extract: expertise, domain knowledge

**Q3**: "How would you describe your communication style? Pick one or describe your own:"
- Offer: `brief and direct` / `detailed and thorough` / `casual and conversational` / `other`
- Extract: tone preference

### Step 2 — Work Context

**Q4**: "What are your 1-3 main projects right now? Just name + one-liner for each."
- Example: "Acme API — REST API for our mobile app"
- Extract: project names, descriptions

**Q5**: "What's your tech stack? (languages, frameworks, hosting — whatever you use regularly)"
- Extract: languages, frameworks, infra

**Q6**: "What project/task management tools do you use?"
- Offer: `Trello` / `Linear` / `Jira` / `GitHub Issues` / `Notion` / `none` / `other`
- Extract: PM tool

### Step 3 — Preferences

**Q7**: "Any pet peeves with AI assistants? Things you want me to never do?"
- Examples: "don't over-explain", "no emojis", "don't summarize after every action"
- Extract: negative preferences → will become feedback memories

**Q8**: "Anything else you want me to always remember about how you work?"
- Open-ended catch-all
- Extract: additional preferences

### Step 4 — Location

**Q9**: "Where do you want your knowledge base? Default is `~/Documents/knowledge-base/` — just say 'default' or give me a path."
- Default: `~/Documents/knowledge-base/`
- Accept any valid absolute path. Create parent directories if needed.
- Store this as `$KB_PATH` for all subsequent steps.

### Step 5 — Build Everything

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
  ├── resources/
  ├── _private/
  │   └── credentials.md
  ├── _analytics/
  │   ├── usage.log               (skill invocation log — auto-populated)
  │   └── weekly-summary.md       (consolidated weekly — auto-generated)
  ├── claude-memory/                    → ~/.claude/.../memory/
  ├── claude-skills/                    → ~/.claude/skills/
  ├── .gitignore
  └── README.md

  ~/.claude/.../memory/
  ├── MEMORY.md
  ├── MEMORY-extended.md
  ├── user_profile.md
  ├── feedback_preferences.md
  ├── feedback_health_check.md
  └── feedback_memory_size.md
```

Then create everything immediately:

#### 5a — Knowledge Base Structure

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
├── resources/
├── _private/
│   └── credentials.md
├── _analytics/
│   ├── usage.log
│   └── weekly-summary.md
├── claude-memory/           ← symlinked
├── claude-skills/           ← symlinked
├── .gitignore
└── README.md
```

#### 5b — File Contents

**me/profile.md:**
```markdown
# {Name} — Profile

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
- Style: {from Q3 — e.g., "brief and direct"}
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
Active — added during onboarding

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
> Claude can read this file to deploy and manage your services.

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
# Books — Domain Knowledge Libraries

Each book is a folder with a `_toc.md` index and chapter files.

## Recommended Format

### Table of Contents (`_toc.md`)
```markdown
# Book Title

## Chapters
- [Chapter 1: Title](ch01-file.md) — *Use when: brief hint about when to load this chapter*
- [Chapter 2: Title](ch02-file.md) — *Use when: another hint*
```

The "Use when" hints help Claude load only relevant chapters instead of the entire book, saving tokens.

### Chapter Files
Name as `ch{NN}-{slug}.md`. Keep chapters focused on one topic.

## When to Create a Book
After you've accumulated 3+ learnings in a domain from real project work. Don't create books preemptively — let patterns emerge from practice.
```

**_analytics/usage.log** — create as an empty file.

**_analytics/weekly-summary.md:**
```markdown
# Weekly Skill Analytics

No data yet. First summary will appear after one week of skill usage.
```

**README.md:**
```markdown
# Knowledge Base

Personal knowledge base powered by Claude Code. This is your AI's long-term memory.

## Structure
- `me/` — profile, tone of voice, personal context
- `projects/` — one folder per project (overview, architecture, decisions)
- `career/` — CV, job search, interview prep
- `books/` — reference libraries that grow with your expertise
- `resources/` — reference material, guides, external docs
- `_private/` — credentials and secrets (git-ignored, never synced)
- `claude-memory/` — persistent memory across conversations (symlinked)
- `claude-skills/` — reusable prompt templates (symlinked)

## Privacy
This repo should be **private**. It contains your professional profile, project details,
and preferences. The `_private/` folder is git-ignored for credentials, but everything
else (your role, projects, communication style) is in the repo.

If you need to share specific files publicly, copy them out rather than making the repo public.

## Setup
Created with [Trestle](https://github.com/liormesh/trestle).
```

#### 5c — Memory System

Determine the correct memory path. **Always use the user's home directory** (not the current working directory) to construct this path. The pattern is:
`~/.claude/projects/-{home-path-with-slashes-and-backslashes-replaced-by-dashes}/memory/`

**macOS/Linux:** Run `echo $HOME`. Replace each `/` with `-`.
- `$HOME=/Users/john` → `~/.claude/projects/-Users-john/memory/`
- `$HOME=/home/john` → `~/.claude/projects/-home-john/memory/`

**Windows:** Run `echo $env:USERPROFILE`. Replace each `\` with `-`, drop the colon.
- `C:\Users\john` → `~/.claude/projects/-C-Users-john/memory/`

Create the directory if it doesn't exist.

**Create MEMORY.md:**
```markdown
# {Name} — Persistent Context

## Who
- {Role} at {Company}
- Expertise: {from Q2}
- Style: {from Q3}
- See: KB `me/profile.md`

## Active Projects
{numbered list from Q4, with format: **Name** — description. See: KB `projects/{name}/overview.md`}

## Preferences
{- Feedback preferences link if Q7 had answers}
- See: `feedback_preferences.md`
- `feedback_health_check.md` — run build/dev check before coding sessions; skip for quick edits or read-only tasks

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

**Create feedback_preferences.md** (only if Q7 had answers):
```markdown
---
name: feedback_preferences
description: User's stated preferences for AI assistant behavior — things to always do or never do
type: feedback
---

{Each pet peeve from Q7 as a bullet point, framed as a clear instruction}
```

**Always create feedback_health_check.md** (this is a built-in best practice, not user-dependent):
```markdown
---
name: feedback_health_check
description: Run a build/dev-server check before coding sessions on projects, but skip for quick edits, planning, or read-only tasks
type: feedback
---

Before writing code in a project, run a quick health check (build or dev server) to verify the baseline is clean.

**Why:** Catches drift between sessions — broken deps, stale env, half-finished migrations — before you're deep into new work.

**How to apply:**
- **Do it** when: feature work or refactoring, days since last session, active dependency churn
- **Skip it** when: quick config/content/copy edits, just worked on the project last session, read-only tasks (analysis, planning, writing, reviews)
- Keep it lightweight — one command (`npm run dev`, `npm run build`, or equivalent), not a full test suite
- If the check surfaces errors, flag them before starting the requested task
```

**feedback_memory_size.md** (always created):
```markdown
---
name: MEMORY.md size limit
description: MEMORY.md must stay under 50 lines — it's the elevator pitch, not the filing cabinet
type: feedback
---

MEMORY.md is loaded into EVERY conversation. Keep it under 50 lines: identity, top-3 projects, critical behavioral rules only.

Everything else goes in MEMORY-extended.md (loaded on demand by skills and agents).

**Why:** At ~30 tokens per line, a 100-line MEMORY.md burns 3K tokens before you say a word — every conversation, whether relevant or not.

**How to apply:**
- When updating MEMORY.md, if it exceeds 50 lines, move overflow to MEMORY-extended.md
- MEMORY.md = elevator pitch (who, what's active, critical rules)
- MEMORY-extended.md = full context (all projects, org details, career, references)
```

**MEMORY-extended.md** (always created — empty overflow target):
```markdown
# {Name} — Extended Context

> This file is loaded on demand by skills and agents. For the compact version, see MEMORY.md.

## All Projects
{Move additional projects here as MEMORY.md grows}

## References
{Credentials, integrations, external systems}

## Career
{Goals, hiring, job search context}
```

#### 5d — Symlinks

Create symlinks connecting the KB to Claude's directories. Detect the OS and use the right command.

**macOS/Linux:**
```bash
ln -sfn {memory_path} {$KB_PATH}/claude-memory
ln -sfn ~/.claude/skills {$KB_PATH}/claude-skills
```

**Windows (PowerShell — requires Developer Mode or admin):**
```powershell
New-Item -ItemType SymbolicLink -Path "{$KB_PATH}\claude-memory" -Target "{memory_path}" -Force
New-Item -ItemType SymbolicLink -Path "{$KB_PATH}\claude-skills" -Target "$env:USERPROFILE\.claude\skills" -Force
```

If Windows symlinks fail (no admin/dev mode), fall back to printing a note:
"Symlinks require Developer Mode on Windows. Enable it in Settings > For developers, then re-run /onboard. Or create the links manually."

#### 5e — Settings

If `~/.claude/settings.json` doesn't exist, create it:

```json
{
  "permissions": {
    "additionalDirectories": [
      "{$KB_PATH}",
      "/tmp"
    ]
  }
}
```

If it already exists, check if `$KB_PATH` is in `additionalDirectories`. If not, add it. Don't overwrite other settings.

#### 5f — Update CLAUDE.md

Replace the bootstrap `~/.claude/CLAUDE.md` with permanent global instructions:

```markdown
# Global Instructions

- Knowledge base: {$KB_PATH}
- Credentials: {$KB_PATH}/_private/credentials.md
- Memory index: check MEMORY.md for persistent context across conversations
- Skills: available via /skill-name — see claude-skills/ in the KB for the full list
- No standalone feedback files — write feedback inline to the relevant KB file (skill, book, project overview)
- Don't create a skill until you've done the workflow manually 3+ times — check existing skills first
- After invoking a skill, append a line to {$KB_PATH}/_analytics/usage.log
```

Only replace if the current CLAUDE.md contains "First Time Setup" (the bootstrap marker). If the user has a custom CLAUDE.md, leave it alone and print a note suggesting they add the KB path.

### Step 6 — Summary

Print a recap. Don't ask for permission, just show what was done:

```
Done! Here's your workspace:

**Knowledge Base** ({$KB_PATH})
  me/profile.md .............. your profile
  me/tone-of-voice.md ....... communication style
  projects/ .................. {list project names}
  books/ ..................... reference libraries (empty, grows over time)
  career/ .................... CV, job search (empty)
  _private/credentials.md .... API keys (git-ignored)

**Memory System** (~/.claude/.../memory/)
  MEMORY.md .................. context index
  user_profile.md ............ your profile memory
  feedback_preferences.md .... your preferences
  feedback_health_check.md ... pre-session build check

**Symlinks**
  claude-memory/ → memory system
  claude-skills/ → skills directory

**Settings**
  ~/.claude/CLAUDE.md ........ global instructions (updated)
  ~/.claude/settings.json .... KB path added

**Next steps:**
1. Add API keys to _private/credentials.md
2. Flesh out your project overviews in projects/
3. As we work together, I'll learn and grow the memory system automatically
4. Sync to GitHub (private): cd {$KB_PATH} && git init && gh repo create knowledge-base --private --push
5. Review skill analytics monthly — check _analytics/weekly-summary.md to spot unused skills or improvement opportunities

You're all set. What would you like to work on?
```

## Compatibility

Tested with Claude Code v2.1.x. The scaffolded files are standard markdown — if Claude Code's internal format changes, your knowledge base content is safe. Only the memory frontmatter format (name/description/type) and SKILL.md format are Claude Code-specific.

## Error Handling

- If `$KB_PATH` already exists, detect it and ask: "You already have a workspace. Want to: (a) update your profile, (b) add new projects, (c) start fresh?" This is the only time /onboard pauses for input after the interview.
- If symlink targets don't exist, create the directories first.
- If any file write fails, report it and continue with the rest.
- If the user skips a question, use sensible defaults (empty project list, "direct" tone, etc.)

## Re-run Safety

If the user runs /onboard again:
- Detect existing KB and memory files at Step 0 (before the welcome message)
- Ask: "You already have a workspace at {$KB_PATH}. Want to: (a) update your profile, (b) add new projects, (c) start fresh?"
- Options (a) and (b) never overwrite existing files — they only update or add.
- Option (c) backs up the existing KB to `{$KB_PATH}.bak.{timestamp}` before starting fresh.
