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

**Q9**: "Where do you want your knowledge base? Press enter for the default, or type a path."
- Default: `~/Documents/knowledge-base/`
- Accept any valid path. Create parent directories if needed.
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
  ├── claude-memory/                    → ~/.claude/.../memory/
  ├── claude-skills/                    → ~/.claude/skills/
  ├── .gitignore
  └── README.md

  ~/.claude/.../memory/
  ├── MEMORY.md
  ├── user_profile.md
  └── feedback_preferences.md
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
Created with [Claude Onboard Kit](https://github.com/liormesh/claude-onboard-kit).
```

#### 5c — Memory System

Determine the correct memory path. The path follows this pattern:
`~/.claude/projects/-{absolute-path-with-dashes}/memory/`

Where the path is the user's home directory with slashes replaced by dashes. For example:
- Home `/Users/john` → `~/.claude/projects/-Users-john/memory/`
- Home `/home/john` → `~/.claude/projects/-home-john/memory/`

Run `whoami` and construct the path accordingly. Create the directory if it doesn't exist.

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

#### 5d — Symlinks

Create symlinks connecting the KB to Claude's directories:

```bash
# Memory → KB
ln -sfn {memory_path} {$KB_PATH}/claude-memory

# Skills → KB
ln -sfn ~/.claude/skills {$KB_PATH}/claude-skills
```

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

You're all set. What would you like to work on?
```

## Compatibility

Tested with Claude Code v1.x. The scaffolded files are standard markdown — if Claude Code's internal format changes, your knowledge base content is safe. Only the memory frontmatter format (name/description/type) and SKILL.md format are Claude Code-specific.

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
