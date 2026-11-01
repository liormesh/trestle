---
name: feedback-no-standalone-feedback
description: New feedback goes inline in the relevant KB file (skill, book chapter, project overview), not a new memory file
metadata:
  type: feedback
  trestle: 1.8.0
---

When the user gives feedback ("don't do X", "always do Y"), write it inline into the KB file it relates to:
- Skill behavior feedback → into that skill's SKILL.md
- Project-specific feedback → into `projects/<name>/overview.md`
- Book/reference feedback → into the relevant chapter
- Tone/voice feedback → into `me/tone-of-voice.md` or the relevant register

**Only cross-cutting behavioral rules that apply to most sessions** stay in `claude-memory/` as standalone `feedback-<slug>.md` files. Those are rare - health check, memory-size, deploy conventions. Most feedback is contextual and belongs next to the thing it modifies.

**Why:** Standalone feedback files proliferate fast and lose their anchor. A rule like "don't use lexicon-based sentiment, use Haiku" only makes sense next to the sentiment analysis docs. Stored as `feedback-sentiment.md` in memory, it gets recalled out of context and applied where it doesn't fit.

**How to apply:**
- Default: find the KB file this feedback relates to and append a note there
- Promote to `claude-memory/` only if the rule genuinely cross-cuts most conversations - and then add a one-line pointer to MEMORY.md, or it can never be recalled
- New memory files are named `<type>-<slug>.md` (kebab-case), with `name:` equal to the filename
- If unsure, inline - promoting later is cheap, un-promoting after the rule has been recalled wrongly is not
