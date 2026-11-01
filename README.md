# Trestle

The setup tool I wish existed when I started building with Claude Code.

Most people install Claude Code and start chatting. That works - for about a week. Then you realize the AI doesn't remember your name, keeps suggesting React when you use Vue, and has no idea you've told it three times to stop adding emojis.

The fix isn't a better prompt. It's a better workspace.

That workspace is a three-legged stool: a **Brain** (the model you talk to), **Agents** (skills plus the tools to do real work), and **Context** (everything it should remember and know). The Brain is Claude Code itself - Trestle builds the other two legs.

**Trestle** is an interactive setup tool that scaffolds your Context and wires up your Agents in 5 minutes. It asks who you are, what you build, and how you like to work, then sets up the knowledge base, memory, and skills that make every conversation smarter than the last.

## Quick Start

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed (CLI, VS Code extension, or desktop app)
- macOS, Linux, or Windows
- [Node.js](https://nodejs.org) 18+ (for the guardrail hooks and the `/73` health check - no packages, just `node`)

### Install

**macOS / Linux:**
```bash
git clone https://github.com/liormesh/trestle /tmp/trestle && /tmp/trestle/install.sh
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/liormesh/trestle $env:TEMP\trestle; & $env:TEMP\trestle\install.ps1
```

This copies the starter skills (`/onboard`, `/cq`, `/73`, `/visualize`), three small guardrail tools (`~/.claude/trestle/`) and a bootstrap file to `~/.claude/`. That's it - read the script ([bash](install.sh) | [powershell](install.ps1)), it's ~90 lines.

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
│       └── overview.md         ← stable description + state: project | area | archive | icebox
├── pm/
│   └── handoff/                ← live status per project - what /cq reads first
├── career/                     ← CV, job search, interviews
├── books/
│   ├── README.md               ← how to structure knowledge books
│   └── dataviz/                ← shipped example book (powers /visualize)
├── resources/                  ← guides, external docs
├── _private/
│   └── credentials.md          ← API keys (never leaves your machine)
├── _analytics/
│   ├── usage.log               ← one line per skill run (the sweep reads it)
│   └── baseline.json           ← the health-check ratchet (created by the first /73)
├── claude-memory/              → persistent memory (symlinked)
├── claude-skills/              → reusable skills (symlinked)
├── _first-run-check.md         ← "is it alive?" check: read it back in a fresh session
└── .gitignore
```

`_first-run-check.md` is a cold file holding a distinctive magic word. In a fresh session, ask *"Read
_first-run-check.md and tell me the magic word"* - a correct reply proves the setup works end to end: the
engine runs **and** it can pull a file on demand. (It's also the workshop's first checkpoint.)

A **hot layer** (memory) - persistent context loaded into every conversation:

```
~/.claude/.../memory/
├── MEMORY.md                              ← index: identity, rules, preferences, pointers - no live status
├── MEMORY-extended.md                     ← overflow context (loaded on demand)
├── user-profile.md                        ← your role, expertise, communication style
├── feedback-health-check.md               ← pre-session build check
├── feedback-memory-size.md                ← signal density + no live status in the index
├── feedback-no-standalone-feedback.md     ← new feedback goes inline, not into new files
├── feedback-memory-decay.md               ← the sweep (active / archive / promote) - /73 says when it's due
└── project-skill-backlog.md               ← logs 3x-rule skill candidates as they recur
```

### Agents - how it acts

Skills (reusable workflows) plus the tools to run them, wired up under `~/.claude/skills/` with an `_index.md` catalog. Four skills ship out of the box so you're not staring at an empty catalog:

- **`/onboard`** - the setup interview (re-runnable).
- **`/cq <project>`** - the opening call. Tunes a session into one project's full context (its handoff doc first, then the overview, state, gotchas, health check) before you start. This is the Context leg as a one-command ritual.
- **`/73`** - the sign-off. Runs the workspace health check, then *writes the session's learnings back* to memory and the KB. This is the ritual that runs the growth loop - corrections become memory and finished work accumulates, on purpose, instead of by luck. It also runs the 3x rule: if a workflow recurred enough to be worth encoding, `/73` offers to turn it into a skill on the spot. Built to be cheap: three tool calls, a smaller model.
- **`/visualize`** - a ready working skill: turns a plan, report, or dataset into a **self-contained HTML or PDF** artifact (one file, opens offline). It's also the worked example of the **skill + book** pattern - it ships paired with a `dataviz` book in `books/`, and loads that book's chapters on demand instead of carrying the craft in its own body.

**And, at the end of setup, your first *own* skill.** Onboarding closes by asking for one task you *already* do every week - a report you pull, a check you always run - and builds it into a real skill with you, then runs it once so you watch it fire. This is importing a habit, not inventing one, so it doesn't break the 3x rule below. If you don't have one yet, that's the right answer too: nothing gets built, and you leave knowing exactly what earns the next skill.

You add more agents the same way as repeatable work emerges - the rule is to build one only after you've done the task by hand 3+ times (logged in `project-skill-backlog.md`).

**Settings** - global instructions, two guardrail hooks (below) and a starter permission **seatbelt** (not a cage), configured automatically. The deny list catches the obvious foot-guns (`rm -rf`, force-push, reading `.env`); it is a coarse backstop, **not a security boundary** - pattern rules don't see a `DROP TABLE` that arrives inside `psql -c` or an MCP call. Real control is the permission *mode* you run in. Treat `_private/credentials.md` the same way: handing Claude the keys is a convenience with a real blast radius - put in only what you need it to act on.

## How It Stays Healthy

A workspace that grows also drifts: links break, memory fills with stale status, projects stall without anyone deciding to stop them. Trestle's answer comes from watching a real workspace over months:

> **Rules get forgotten. Rituals hold. Checks that fail hold best.**
> Everything written as "do this monthly" quietly stopped happening. Everything attached to a ritual that already fires (open a session, close a session) kept running. And the problems that stayed fixed were the ones a check would *fail* on, not the ones a rule asked nicely about.

So upkeep is built in three layers, none of which needs a calendar:

| Layer | What | When it runs |
|---|---|---|
| **Hooks** | **Secret guard** - blocks a write into your KB / memory / skills that contains an API key or token (except in `_private/`). A committed key stays in git history even after you delete it; the only fix is rotating it, so it's stopped at write time. **Link guard** - after every markdown write, reports links that point at nothing, with a did-you-mean. | On every write Claude makes |
| **The `/73` health check** | `kb-check.mjs`: broken links, secrets, memory files with bad frontmatter or no index line, misplaced `state:` fields, MEMORY.md size and dated (volatile) lines, projects stalled 45+ days, an overdue memory sweep, uncommitted work. Each WARN gets fixed before signing off. | Every sign-off |
| **The ratchet** | `_analytics/baseline.json` records vault-wide problem counts. They may go down (the baseline tightens automatically), never up - pre-existing mess is recorded, not blamed, and can't silently grow. | Every sign-off |

Run the check yourself any time: `node ~/.claude/trestle/kb-check.mjs` (`--usage 30` shows which skills you actually use).

Honest scope, again: the hooks see writes made through Claude's edit tools, not text a shell command writes. They are seatbelts.

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

Each project overview has a `## Health Check` section where you define the command. Claude skips the check for quick edits, planning, or read-only tasks - it only runs when you're about to write code and it's been a while since the last session.

## Framework Rules

Trestle scaffolds a few guardrails that prevent common drift patterns:

- **MEMORY.md is governed by signal density and volatility, not line count.** Every line should affect Claude's behavior in roughly 1-in-5 conversations - and **no live status goes in it**. "Launching Thursday" or "waiting on legal" lives in the project's handoff doc; MEMORY.md points there. Volatile lines in the always-loaded index go stale, get edited constantly (each edit defeats prompt caching), and end up disagreeing with the project doc. Soft cap ~100 lines as a smell test. Overflow goes to `MEMORY-extended.md`.
- **Project state lives in one field.** Each `projects/<p>/overview.md` carries `state: project | area | archive | icebox` and `state_changed:`. "What's in flight?" is a grep, not a re-read - and a `project` that hasn't moved in 45 days gets flagged, because a project is supposed to finish.
- **Feedback goes inline.** Don't create standalone feedback files - write corrections directly into the relevant KB file (skill, book chapter, project overview). Only genuinely cross-cutting rules stay in `claude-memory/`.
- **Skills need 3 repetitions.** Don't encode a workflow as a skill until you've done it manually at least 3 times. Log candidates in `claude-memory/project-skill-backlog.md`; check `claude-skills/_index.md` first - an existing skill may just need a new mode.
- **The memory sweep is triggered by `/73`, not a calendar.** After 30 days the health check reports `SWEEP: OVERDUE`, and the next session runs an active / archive / promote pass - `claude-memory/feedback-memory-decay.md`.
- **Analytics have one format.** Each skill run appends `<ISO-UTC> <skill> <note>` to `_analytics/usage.log`; the sweep reads it with `kb-check.mjs --usage 30` to spot dead-weight skills and recurring manual work worth a skill.
- **Memory files are named `<type>-<slug>.md`**, with `name:` equal to the filename and a pointer line in MEMORY.md - an unindexed memory can never be recalled.

## What's Private?

Your knowledge base contains personal professional context - your name, role, company, projects, expertise, and communication preferences. Here's how privacy works:

| What | Where | Visibility |
|------|-------|-----------|
| Credentials, API keys | `_private/` | **Git-ignored** - never leaves your machine |
| Profile, projects, preferences | `me/`, `projects/`, memory files | **In your repo** - keep the repo private |
| Skills, books, resources | `claude-skills/`, `books/` | **In your repo** - keep the repo private |
| `_analytics/` | | In repo (not sensitive) |

**The KB repo should be private.** When you sync to GitHub, use:

```bash
cd ~/Documents/knowledge-base && git init && gh repo create knowledge-base --private --push
```

If you ever need to share specific files publicly, copy them out rather than making the repo public.

> **Windows note:** Symlinks require [Developer Mode](https://learn.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development) enabled. If symlink creation fails during onboarding, Claude will tell you how to fix it.

## Compatibility

Tested with Claude Code v2.1.x on macOS, Linux, and Windows. The knowledge base is standard markdown - if Claude Code's internals change, your content is safe. If something breaks after an update, [open an issue](https://github.com/liormesh/trestle/issues).

## Re-running and Upgrading

Running `/onboard` again is safe. It detects your existing workspace and offers to (a) update your profile, (b) add new projects, (c) start fresh (with backup), or (d) **update the framework**.

**To upgrade to a new Trestle version:** re-run the install one-liner (it updates the starter skills and tools, backing up the old copies to `~/.claude/trestle/backups/`), then `/onboard` → (d). Option (d) renames legacy files, refreshes the shipped rule files you never edited, asks before touching ones you did, adds whatever's new (handoff docs, project states, hooks), and never rewrites your own content. The `/73` health check tells you when the tools are newer than your workspace.

## This Is Opinionated

This setup reflects how I actually work - multiple projects, persistent memory, structured knowledge base, everything symlinked together. It's the system I've refined over months of daily use with Claude Code.

It won't fit everyone. But if you're building things and want an AI that actually knows your context, this is a solid starting point. Everything is editable after setup.

## Development

Dev scripts live in `dev/`. To test the install script without touching your real config:

```bash
bash dev/test-fresh-user.sh   # install + upgrade path, then the tool tests
bash dev/test-tools.sh        # hooks + health check against a fixture workspace with planted defects
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release notes.

## License

MIT - see [LICENSE](LICENSE).

---

Built at [Revgineer](https://revgineer.com) - a lab for things that should exist.
