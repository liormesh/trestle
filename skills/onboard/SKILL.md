---
name: onboard
description: Interactive onboarding for new Claude Code users. Interviews the user about their role, projects, preferences, and tools, then scaffolds their entire AI workspace — knowledge base, memory system, profile, settings, and folder structure. Run once on first setup. Triggers on 'onboard', 'set up my workspace', 'first time setup', 'get started'.
---

# /onboard — Claude Code Workspace Setup

## Overview

You are an onboarding assistant. Your job is to interview the user with a short, friendly questionnaire, then use their answers to scaffold a complete Claude Code workspace: knowledge base, memory system, profile, tone register, project stubs, and settings.

**Tone**: Warm, efficient, slightly playful. This is their first impression of what Claude can do — make it count. Keep questions conversational, not like a form.

## Flow

### Step 0 — Welcome

Print this (adjust if re-running):

```
Welcome! I'm going to set up your AI workspace — a personal knowledge base, memory system, and profile that makes every future conversation smarter.

Takes about 5 minutes. I'll ask a few questions, then build everything automatically. You can always change things later.

Let's go.
```

### Step 1 — Identity (ask as ONE question block)

Ask the user (use the AskUserQuestion tool for EACH question, one at a time):

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

### Step 4 — Expertise Level (infer, don't ask)

Based on the answers so far, classify the user:
- **Beginner**: Non-technical role, no mention of CLI/git/code, simple projects → minimal scaffold
- **Intermediate**: Technical but new to AI tools, some coding → standard scaffold  
- **Power user**: Developer/engineer, complex stack, multiple projects → full scaffold

This determines how much structure to create (see scaffold section).

### Step 5 — Build Everything

Print: "Got it. Building your workspace now..."

#### 5a — Knowledge Base Structure

Create `~/Documents/knowledge-base/` with this structure:

```
~/Documents/knowledge-base/
├── me/
│   ├── profile.md          ← from Q1, Q2
│   └── tone-of-voice.md    ← from Q3
├── projects/
│   └── {project-name}/     ← one per project from Q4
│       └── overview.md     ← stub with name + description
├── books/                  ← empty directory (grows over time)
├── _private/
│   └── credentials.md      ← empty template
├── claude-memory/           ← will be symlinked
├── claude-skills/           ← will be symlinked
├── .gitignore
└── README.md
```

**For intermediate/power users, also create:**
```
├── career/                  ← empty, for CV/job search later
├── resources/               ← empty, for reference material
```

#### 5b — File Contents

**me/profile.md:**
```markdown
# {Name} — Profile

## Role
{Role} at {Company}

## Expertise
{Expertise from Q2}

## Communication Style
{From Q3}

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
```

**projects/{name}/overview.md:**
```markdown
# {Project Name}

## What
{One-liner from Q4}

## Tech Stack
{Relevant parts from Q5}

## Status
Active — added during onboarding
```

**_private/credentials.md:**
```markdown
# Credentials

> This file is .gitignore'd and never synced to GitHub.
> Store API keys, tokens, and passwords here.

## Example
```
SERVICE_NAME:
  url: https://...
  api_key: xxx
```
```

**.gitignore:**
```
_private/
.DS_Store
*.swp
```

**README.md:**
```markdown
# Knowledge Base

Personal knowledge base for Claude Code. Synced to GitHub (except `_private/`).

## Structure
- `me/` — profile, tone, personal context
- `projects/` — one folder per project
- `books/` — reference libraries (grow over time)
- `_private/` — credentials (git-ignored)
- `claude-memory/` — symlinked from Claude's memory system
- `claude-skills/` — symlinked from Claude's skills directory

## Setup
Created with [Claude Onboard Kit](https://github.com/liormesh/claude-onboard-kit).
```

#### 5c — Memory System

Create the memory directory if it doesn't exist:
`~/.claude/projects/-Users-{username}/memory/`

Note: Replace `{username}` with the actual macOS username (run `whoami`).

**Create MEMORY.md:**
```markdown
# {Name} — Persistent Context

## Who
- {Role} at {Company}
- Expertise: {from Q2}
- Style: {from Q3}
- See: KB `me/profile.md`

## Active Projects
{numbered list from Q4, each linking to KB projects/{name}/overview.md}

## KB Structure
- Vault: `~/Documents/knowledge-base/`
- Auto-memory: `claude-memory/` (symlinked)
- Secrets: `_private/` (.gitignore'd)
```

**Create user_profile.md:**
```markdown
---
name: user_profile
description: {Name}'s role, expertise, and communication preferences
type: user
---

{Name} is a {role} at {company}. Expertise in {domain}. Prefers {communication style} communication.
{Any additional context from Q8}
```

**Create feedback_preferences.md** (only if Q7 had answers):
```markdown
---
name: feedback_preferences
description: User's stated preferences for AI assistant behavior
type: feedback
---

{Each pet peeve from Q7 as a bullet point}
```

#### 5d — Symlinks

Create symlinks connecting the KB to Claude's directories:

```bash
# Memory → KB
ln -sfn ~/.claude/projects/-Users-{username}/memory ~/Documents/knowledge-base/claude-memory

# Skills → KB  
ln -sfn ~/.claude/skills ~/Documents/knowledge-base/claude-skills
```

#### 5e — Settings

If `~/.claude/settings.json` doesn't exist, create it with sensible defaults:

```json
{
  "permissions": {
    "additionalDirectories": ["/tmp"]
  }
}
```

If it already exists, don't overwrite — just note what's already there.

#### 5f — Update CLAUDE.md

Replace the bootstrap `~/.claude/CLAUDE.md` (if it exists and contains the bootstrap trigger) with:

```markdown
# Global Instructions

- Knowledge base: ~/Documents/knowledge-base/
- Credentials: ~/Documents/knowledge-base/_private/credentials.md
- Memory index: check MEMORY.md for persistent context
```

### Step 6 — Summary

Print a recap of everything created:

```
Done! Here's what I set up:

**Knowledge Base** (~/Documents/knowledge-base/)
- Profile: me/profile.md
- Tone: me/tone-of-voice.md  
- Projects: {list project folders}
- Credentials template: _private/credentials.md

**Memory System**
- MEMORY.md index
- User profile memory
{- Preferences memory (if created)}

**Symlinks**
- claude-memory/ → memory system
- claude-skills/ → skills directory

**Next steps:**
1. Add your API keys to _private/credentials.md
2. Flesh out your project overviews in projects/
3. As we work together, I'll learn your preferences and grow the memory system
4. Want to sync your KB to GitHub? Run: cd ~/Documents/knowledge-base && git init && gh repo create knowledge-base --private --push

You're all set. What would you like to work on?
```

## Error Handling

- If `~/Documents/knowledge-base/` already exists, ask before overwriting. Offer to merge or skip.
- If symlink targets don't exist, create the directories first.
- If any file write fails, report it and continue with the rest.
- If the user skips a question, use sensible defaults (empty project list, "direct" tone, etc.)

## Re-run Safety

If the user runs /onboard again:
- Detect existing KB and memory files
- Ask: "You already have a workspace set up. Want to: (a) update your profile, (b) add new projects, (c) start fresh?"
- Never silently overwrite existing files.
