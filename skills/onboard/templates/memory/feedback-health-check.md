---
name: feedback-health-check
description: Run a build/dev-server check before coding sessions on projects, but skip for quick edits, planning, or read-only tasks
metadata:
  type: feedback
  trestle: 1.8.0
---

Before writing code in a project, run a quick health check (build or dev server) to verify the baseline is clean.

**Why:** Catches drift between sessions - broken deps, stale env, half-finished migrations - before you're deep into new work.

**How to apply:**
- **Do it** when: feature work or refactoring, days since last session, active dependency churn
- **Skip it** when: quick config/content/copy edits, just worked on the project last session, read-only tasks (analysis, planning, writing, reviews)
- Keep it lightweight - one command (`npm run dev`, `npm run build`, or equivalent), not a full test suite. The command lives in the project overview's `## Health Check` section
- If the check surfaces errors, flag them before starting the requested task
