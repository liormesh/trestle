# Trestle

The setup tool I wish existed when I started building with Claude Code.

Most people install Claude Code and start chatting. That works — for about a week. Then you realize the AI doesn't remember your name, keeps suggesting React when you use Vue, and has no idea you've told it three times to stop adding emojis.

The fix isn't a better prompt. It's a better workspace.

**Trestle** is an interactive setup tool that builds your personal AI workspace in 5 minutes. It asks who you are, what you build, and how you like to work — then scaffolds a knowledge base, memory system, and profile that makes every conversation smarter than the last.

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

This copies one skill and one file to `~/.claude/`. That's it — read the script ([bash](install.sh) | [powershell](install.ps1)), it's ~30 lines.

### Run

Open Claude Code **from your home directory** and type:

```bash
cd ~
/onboard
```

~8 questions, ~5 minutes, fully automated setup.

## What It Does

Claude asks about your role, projects, tech stack, and preferences, then builds:

**A Knowledge Base** — structured folder for everything Claude needs to know about you:

```
~/Documents/knowledge-base/     (or wherever you choose)
├── me/
│   ├── profile.md              ← who you are, what you do
│   └── tone-of-voice.md        ← how you communicate
├── projects/
│   └── {your-projects}/        ← one folder per project
│       └── overview.md
├── career/                     ← CV, job search, interviews
├── books/                      ← reference libraries (grow over time)
├── resources/                  ← guides, external docs
├── _private/
│   └── credentials.md          ← API keys (never leaves your machine)
├── claude-memory/              → persistent memory (symlinked)
├── claude-skills/              → reusable skills (symlinked)
└── .gitignore
```

**A Memory System** — persistent context that follows you across conversations:

```
~/.claude/.../memory/
├── MEMORY.md                   ← index of everything Claude remembers
├── user_profile.md             ← your role, expertise, preferences
├── feedback_preferences.md     ← things Claude should always/never do
└── feedback_health_check.md    ← pre-session build check
```

**Settings** — global instructions and configuration wired up automatically.

## How It Works After Setup

The system grows with you:
- When you correct Claude ("don't do X"), it saves a **feedback memory** so it never repeats the mistake
- As you work on projects, context accumulates in project overviews and memory
- You can add **skills** (reusable prompt templates) and **books** (reference libraries) as your needs grow
- After a month, Claude knows your stack, your style, and your projects well enough to be genuinely useful

### Health Check

One built-in behavior ships with every install: before writing code in a project, Claude runs a quick health check (`npm run build`, `cargo check`, or whatever your project uses) to verify the baseline is clean. This catches broken deps, stale env, and half-finished migrations before you're deep into new work.

Each project overview has a `## Health Check` section where you define the command. Claude skips the check for quick edits, planning, or read-only tasks — it only runs when you're about to write code and it's been a while since the last session.

## What's Private?

Your knowledge base contains personal professional context — your name, role, company, projects, expertise, and communication preferences. Here's how privacy works:

| What | Where | Visibility |
|------|-------|-----------|
| Credentials, API keys | `_private/` | **Git-ignored** — never leaves your machine |
| Profile, projects, preferences | `me/`, `projects/`, memory files | **In your repo** — keep the repo private |
| Skills, books, resources | `claude-skills/`, `books/` | **In your repo** — keep the repo private |

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

## License

MIT — see [LICENSE](LICENSE).

---

Built at [Revgineer](https://revgineer.com) — a lab for things that should exist.
