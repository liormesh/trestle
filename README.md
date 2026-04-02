# Claude Onboard Kit

Set up a complete Claude Code AI workspace in 5 minutes. An interactive onboarding tool that creates your personal knowledge base, memory system, and profile.

## What You Get

- **Knowledge Base** (`~/Documents/knowledge-base/`) — structured folder for your profile, projects, credentials, and reference material
- **Memory System** — persistent context that follows you across conversations
- **Profile & Tone** — Claude learns who you are, what you do, and how you communicate
- **Project Stubs** — ready-to-grow documentation for your active projects

## Quick Start

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed (CLI, VS Code extension, or desktop app)
- macOS or Linux

### Install

```bash
git clone https://github.com/liormesh/claude-onboard-kit /tmp/claude-onboard-kit && /tmp/claude-onboard-kit/install.sh
```

### Run

Open Claude Code and type:

```
/onboard
```

Claude will ask ~8 questions about your role, projects, and preferences, then build your entire workspace automatically.

## What Gets Created

```
~/Documents/knowledge-base/
├── me/
│   ├── profile.md          ← who you are
│   └── tone-of-voice.md    ← how you communicate
├── projects/
│   └── {your-projects}/    ← one folder per project
├── books/                  ← reference libraries (grow over time)
├── _private/
│   └── credentials.md      ← API keys (git-ignored)
├── claude-memory/           ← symlinked to memory system
├── claude-skills/           ← symlinked to skills
└── .gitignore

~/.claude/
├── CLAUDE.md               ← global instructions
├── skills/onboard/         ← this tool
└── projects/.../memory/
    ├── MEMORY.md            ← context index
    ├── user_profile.md      ← your profile
    └── feedback_preferences.md ← your preferences
```

## After Onboarding

The system grows organically as you work:
- Claude saves corrections and preferences as **feedback memories**
- Project details get richer as you build
- You can add **skills** (reusable prompt templates) and **books** (reference libraries)
- Sync your KB to GitHub: `cd ~/Documents/knowledge-base && git init && gh repo create knowledge-base --private --push`

## Re-running

Running `/onboard` again is safe — it detects your existing workspace and offers to update rather than overwrite.

## License

MIT
