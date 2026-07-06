# Trestle

The setup tool I wish existed when I started building with Claude Code.

Most people install Claude Code and start chatting. That works — for about a week. Then you realize the AI doesn't remember your name, keeps suggesting React when you use Vue, and has no idea you've told it three times to stop adding emojis.

The fix isn't a better prompt. It's a better workspace.

That workspace is a three-legged stool: a **Brain** (the model you talk to), **Agents** (skills plus the tools to do real work), and **Context** (everything it should remember and know). The Brain is Claude Code itself - Trestle builds the other two legs.

**Trestle** is an interactive setup tool that scaffolds your Context and wires up your Agents in 5 minutes. It asks who you are, what you build, and how you like to work, then sets up the knowledge base, memory, and skills that make every conversation smarter than the last.

## Quick Start

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed (CLI, VS Code extension, or desktop app)
- macOS, Linux, or Windows

### Install

**macOS / Linux:**
```bash
git clone https://github.com/liormesh/trestle /tmp/trestle && /tmp/trestle/install.sh
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/liormesh/trestle $env:TEMP\trestle; & $env:TEMP\trestle\install.ps1
```

This copies the starter skills (`/onboard`, `/cq`, `/73`) and a bootstrap file to `~/.claude/`. That's it — read the script ([bash](install.sh) | [powershell](install.ps1)), it's ~40 lines.

### Run

Open Claude Code **from your home directory** and type:

```bash
cd ~
/onboard
```

~8 questions, ~5 minutes, fully automated setup.

## What It Does

Claude asks about your role, projects, tech stack, and preferences, then builds the two legs that sit on the Brain (Claude Code):

### Context - what it knows & remembers

A **cold layer** (knowledge base) - structured folders for everything Claude should know about you, pulled in on demand:

```
~/Documents/knowledge-base/     (or wherever you choose)
├── me/
│   ├── profile.md              ← who you are, what you do
│   └── tone-of-voice.md        ← how you communicate
├── projects/
│   └── {your-projects}/        ← one folder per project
│       └── overview.md
├── career/                     ← CV, job search, interviews
├── books/
│   └── README.md               ← how to structure knowledge books
├── resources/                  ← guides, external docs
├── _private/
│   └── credentials.md          ← API keys (never leaves your machine)
├── _analytics/
│   ├── usage.log               ← skill invocation log
│   └── weekly-summary.md       ← where you consolidate it (on your sweep)
├── claude-memory/              → persistent memory (symlinked)
├── claude-skills/              → reusable skills (symlinked)
├── _first-run-check.md         ← "is it alive?" check: read it back in a fresh session
└── .gitignore
```

`_first-run-check.md` is a cold file holding a distinctive magic word. In a fresh session, ask *"Read
_first-run-check.md and tell me the magic word"* — a correct reply proves the setup works end to end: the
engine runs **and** it can pull a file on demand. (It's also the workshop's first checkpoint.)

A **hot layer** (memory) - persistent context loaded into every conversation:

```
~/.claude/.../memory/
├── MEMORY.md                              ← identity + cross-cutting rules + your preferences (inline)
├── MEMORY-extended.md                     ← overflow context (loaded on demand)
├── user_profile.md                        ← your role, expertise, communication style
├── feedback_health_check.md               ← pre-session build check
├── feedback_memory_size.md                ← signal-density rule for MEMORY.md
├── feedback_no_standalone_feedback.md     ← new feedback goes inline, not into new files
├── feedback_memory_decay.md               ← periodic active/archive/promote sweep
└── project_skill_backlog.md               ← logs 3x-rule skill candidates as they recur
```

### Agents - how it acts

Skills (reusable workflows) plus the tools to run them, wired up under `~/.claude/skills/` with an `_index.md` catalog. Three skills ship out of the box so you're not staring at an empty catalog:

- **`/onboard`** - the setup interview (re-runnable).
- **`/cq <project>`** - the opening call. Tunes a session into one project's full context (overview, gotchas, deploy rules, health check) before you start. This is the Context leg as a one-command ritual.
- **`/73`** - the sign-off. Runs an end-of-session checklist and *writes the session's learnings back* to memory and the KB. This is the ritual that runs the growth loop - corrections become memory and finished work accumulates, on purpose, instead of by luck.

You add your own agents as repeatable work emerges - the rule is to build one only after you've done the task by hand 3+ times (logged in `project_skill_backlog.md`).

**Settings** - global instructions and safe-by-default permissions, configured automatically.

## How It Works After Setup

The system grows with you:
- When you correct Claude ("don't do X"), it saves a **feedback memory** so it never repeats the mistake
- As you work on projects, context accumulates in project overviews and memory
- End a session with **`/73`** and it writes the session's decisions and learnings back before you go - so "it grows the more you use it" is a ritual, not a hope
- Start a session with **`/cq <project>`** and it loads that project's full context up front - no re-briefing
- You can add **skills** (reusable prompt templates) and **books** (reference libraries) as your needs grow
- After a month, Claude knows your stack, your style, and your projects well enough to be genuinely useful

### Health Check

One built-in behavior ships with every install: before writing code in a project, Claude runs a quick health check (`npm run build`, `cargo check`, or whatever your project uses) to verify the baseline is clean. This catches broken deps, stale env, and half-finished migrations before you're deep into new work.

Each project overview has a `## Health Check` section where you define the command. Claude skips the check for quick edits, planning, or read-only tasks — it only runs when you're about to write code and it's been a while since the last session.

## Framework Rules

Trestle scaffolds a few guardrails that prevent common drift patterns:

- **MEMORY.md is governed by signal density, not line count.** Every line should affect Claude's behavior in roughly 1-in-5 conversations. Soft cap ~60 lines as a smell test, not a hard limit. Overflow that's rarely-but-occasionally needed goes to `MEMORY-extended.md`.
- **Feedback goes inline.** Don't create standalone feedback files — write corrections directly into the relevant KB file (skill, book chapter, project overview). Only genuinely cross-cutting rules stay in `claude-memory/`.
- **Skills need 3 repetitions.** Don't encode a workflow as a skill until you've done it manually at least 3 times. Log candidates in `claude-memory/project_skill_backlog.md`; check `claude-skills/_index.md` first — an existing skill may just need a new mode.
- **Sweep memory periodically.** Monthly (or when MEMORY.md crosses its soft cap), run an active / archive / promote pass so the hot layer stays dense — `claude-memory/feedback_memory_decay.md`.
- **Analytics are passive.** Skill invocations log to `_analytics/usage.log`. Consolidate into `_analytics/weekly-summary.md` on your sweep — there's no background job — to spot dead-weight skills and recurring manual work worth a skill.

## What's Private?

Your knowledge base contains personal professional context — your name, role, company, projects, expertise, and communication preferences. Here's how privacy works:

| What | Where | Visibility |
|------|-------|-----------|
| Credentials, API keys | `_private/` | **Git-ignored** — never leaves your machine |
| Profile, projects, preferences | `me/`, `projects/`, memory files | **In your repo** — keep the repo private |
| Skills, books, resources | `claude-skills/`, `books/` | **In your repo** — keep the repo private |
| `_analytics/` | In repo (not sensitive) |

**The KB repo should be private.** When you sync to GitHub, use:

```bash
cd ~/Documents/knowledge-base && git init && gh repo create knowledge-base --private --push
```

If you ever need to share specific files publicly, copy them out rather than making the repo public.

> **Windows note:** Symlinks require [Developer Mode](https://learn.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development) enabled. If symlink creation fails during onboarding, Claude will tell you how to fix it.

## Compatibility

Tested with Claude Code v2.1.x on macOS, Linux, and Windows. The knowledge base is standard markdown — if Claude Code's internals change, your content is safe. If something breaks after an update, [open an issue](https://github.com/liormesh/trestle/issues).

## Re-running

Running `/onboard` again is safe. It detects your existing workspace and offers to update your profile, add new projects, or start fresh (with backup).

## This Is Opinionated

This setup reflects how I actually work — multiple projects, persistent memory, structured knowledge base, everything symlinked together. It's the system I've refined over months of daily use with Claude Code.

It won't fit everyone. But if you're building things and want an AI that actually knows your context, this is a solid starting point. Everything is editable after setup.

## Development

Dev scripts live in `dev/`. To test the install script without touching your real config:

```bash
bash dev/test-fresh-user.sh
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release notes.

## License

MIT — see [LICENSE](LICENSE).

---

Built at [Revgineer](https://revgineer.com) — a lab for things that should exist.
